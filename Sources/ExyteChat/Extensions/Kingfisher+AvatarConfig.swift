//
//  Kingfisher+AvatarConfig.swift
//  Chat
//
//  Created by AI Assistant on 09/09/2025.
//

import Kingfisher
import SwiftUI

extension KingfisherManager {
    static func configureForAvatars() {
        // Configure Kingfisher for optimal avatar and chat image loading
        let cache = ImageCache.default
        
        // Set optimized cache limits for avatars and chat images
        cache.memoryStorage.config.totalCostLimit = 128 * 1024 * 1024 // 128MB (increased for chat images)
        cache.diskStorage.config.sizeLimit = 512 * 1024 * 1024 // 512MB (increased for chat images)
        
        // Configure downloader for faster loading
        let downloader = ImageDownloader.default
        downloader.downloadTimeout = 15.0 // 15 seconds timeout (increased for larger images)
        
        // Configure cache expiration
        cache.memoryStorage.config.expiration = .seconds(300) // 5 minutes in memory
        cache.diskStorage.config.expiration = .days(7) // 7 days on disk
    }
}

// MARK: - Avatar-specific KFImage extension

extension KFImage {
    func avatarStyle(size: CGFloat) -> some View {
        self
            .resizable()
            .resizing(referenceSize: CGSize(width: 64, height: 64), mode: .aspectFit)
            .fade(duration: 0.2)
            .cacheOriginalImage()
            .viewSize(size)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .drawingGroup()
    }
}
