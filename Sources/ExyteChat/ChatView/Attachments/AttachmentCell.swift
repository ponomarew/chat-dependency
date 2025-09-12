//
//  Created by Alex.M on 16.06.2022.
//

import SwiftUI
import Kingfisher

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

    var content: some View {
        ChatOptimizedImageView(url: attachment.thumbnail)
        
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
            .drawingGroup() // Optimize rendering performance
    }
}
