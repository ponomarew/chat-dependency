//
//  Created by Alex.M on 07.07.2022.
//

import Kingfisher
import SwiftUI

struct AvatarView: View {

    let url: URL?
    let avatarSize: CGFloat

    var body: some View {
        KFImage(url)
            .placeholder {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
            .avatarStyle(size: avatarSize)
            .allowsHitTesting(true) // Ensure taps pass through
            .contentShape(RoundedRectangle(cornerRadius: 12)) // Define tap area
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(
            url: URL(string: "https://placeimg.com/640/480/sepia"),
            avatarSize: 32
        )
    }
}
