//
//  Created by Alex.M on 16.06.2022.
//

import SwiftUI
import Kingfisher
import UIKit
import AVFoundation
import ActivityIndicatorView

struct AttachmentCell: View {

    @Environment(\.chatTheme) private var theme

    let attachment: Attachment
    let onTap: (Attachment) -> Void

    var body: some View {
        Group {
            if attachment.type == .image {
                content
            } else if attachment.type == .video {
                content
                    .overlay {
                        theme.images.message.playVideo
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
            } else {
                content
                    .overlay {
                        Text("Unknown", bundle: .module)
                    }
            }
        }
        .contentShape(Rectangle())
        .highPriorityGesture(
            TapGesture().onEnded { onTap(attachment) }
        )
    }

    @ViewBuilder
    var content: some View {
        if attachment.type == .image {
            ChatOptimizedImageView(url: attachment.thumbnail)
        } else {
            VideoThumbnailView(attachment: attachment)
        }
        
    }
}

struct ChatOptimizedImageView: View {

    @Environment(\.chatTheme) var theme
    let url: URL

    var body: some View {
        KFImage(url)
            .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 350, height: 350)))
            .cacheOriginalImage(false) // Don't cache original for chat
            .placeholder {
                ZStack {
                    Rectangle()
                        .foregroundColor(theme.colors.inputBG)
                        .frame(minWidth: 100, minHeight: 100)
                    ActivityIndicator(size: 30, showBackground: false)
                }
                .allowsHitTesting(false)
            }
            .resizable()
            .scaledToFill()
            // Avoid offscreen rendering to reduce GPU load in long lists
    }
}

struct VideoThumbnailView: View {
    
    let attachment: Attachment
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
            } else {
                ActivityIndicatorView(isVisible: .constant(true), type: .default(count: 8))
                    .foregroundColor(.gray)
                    .frame(width: 18, height: 18)
                    .task {
                        await loadOrGenerateThumbnail()
                    }
                    .onChange(of: attachment.thumbnail) { _ in
                        Task { @MainActor in
                            self.thumbnail = nil
                        }
                        Task {
                            await loadOrGenerateThumbnail()
                        }
                    }
            }
        }
    }

    private var cacheKey: String { "videoThumb-\(attachment.full.absoluteString)" }

    private func loadOrGenerateThumbnail() async {
        // If backend/local provides an image thumbnail URL, show it immediately via Kingfisher
        if isImageURL(attachment.thumbnail) {
            await setThumbnailFromKF(url: attachment.thumbnail)
            return
        }

        if let mem = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: cacheKey) {
            await setThumbnail(mem)
            return
        }

        if let disk = await retrieveDiskCachedImage(forKey: cacheKey) {
            await setThumbnail(disk)
            return
        }

        if let generated = await generateThumbnailWithRetry(url: attachment.full) {
            // Downscale before cache to reduce memory/disk footprint
            let downsized = downscale(image: generated, to: targetThumbnailSize())
            let jpegData = downsized.jpegData(compressionQuality: 0.7)
            KingfisherManager.shared.cache.store(downsized, original: jpegData, forKey: cacheKey)
            await setThumbnail(downsized)
        } else {
            // Fallback to static placeholder to avoid infinite loader
            await setThumbnail(placeholderImage())
        }
    }

    private func retrieveDiskCachedImage(forKey key: String) async -> UIImage? {
        await withCheckedContinuation { continuation in
            KingfisherManager.shared.cache.retrieveImage(forKey: key, options: nil) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value.image)
                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    @MainActor
    private func setThumbnail(_ image: UIImage) {
        self.thumbnail = image
    }

    private func targetThumbnailSize() -> CGSize {
        // Smaller target to reduce AVAssetImageGenerator workload; still crisp for ~204pt cells
        let scale = UIScreen.main.scale
        return CGSize(width: 220 * scale, height: 220 * scale)
    }

    private func downscale(image: UIImage, to target: CGSize) -> UIImage {
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: target.width, height: target.height), format: rendererFormat)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: CGSize(width: target.width, height: target.height)))
        }
    }

    private func generateThumbnail(url: URL, at time: TimeInterval) async -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.apertureMode = .encodedPixels
        generator.maximumSize = targetThumbnailSize()
        generator.requestedTimeToleranceBefore = CMTime(seconds: 0.25, preferredTimescale: 600)
        generator.requestedTimeToleranceAfter = CMTime(seconds: 0.25, preferredTimescale: 600)

        // Try a few timestamps to handle short videos or assets not ready at 0.3s
        let candidates: [TimeInterval] = [time, 0.0, 0.1, 0.5]
        for t in candidates {
            let cmTime = CMTime(seconds: t, preferredTimescale: 60)
            if let cg = try? await generator.image(at: cmTime).image {
                return UIImage(cgImage: cg)
            }
        }
        return nil
    }

    private func generateThumbnailWithRetry(url: URL) async -> UIImage? {
        // Ensure local file is ready before trying to read
        if url.isFileURL {
            var attempts = 0
            while attempts < 5 && !isFileReady(url) {
                try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
                attempts += 1
            }
        }

        // Try a few rounds with small backoff and multiple timestamps
        for _ in 0..<2 {
            if let img = await generateThumbnail(url: url, at: 0.3) { return img }
            if let img = await generateThumbnail(url: url, at: 0.1) { return img }
            if let img = await generateThumbnail(url: url, at: 0.5) { return img }
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
        }
        return nil
    }

    private func isFileReady(_ url: URL) -> Bool {
        guard let values = try? url.resourceValues(forKeys: [.fileSizeKey]),
              let size = values.fileSize else { return false }
        return size > 0
    }

    private func placeholderImage() -> UIImage {
        // Simple light-weight placeholder
        let size = CGSize(width: 120, height: 120)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.systemGray5.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
            let image = UIImage(systemName: "video.fill", withConfiguration: config)?.withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
            image?.draw(in: CGRect(x: (size.width-32)/2, y: (size.height-32)/2, width: 32, height: 32))
        }
    }

    private func isImageURL(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["jpg", "jpeg", "png", "heic", "webp"].contains(ext)
    }

    private func setThumbnailFromKF(url: URL) async {
        await withCheckedContinuation { continuation in
            let res = KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case .success(let value):
                    Task { @MainActor in self.thumbnail = value.image }
                case .failure:
                    break
                }
                continuation.resume()
            }
            _ = res
        }
    }
}
