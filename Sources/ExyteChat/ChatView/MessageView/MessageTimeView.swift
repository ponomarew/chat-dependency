//
//  Created by Alex.M on 08.07.2022.
//

import SwiftUI

struct MessageTimeView: View {

    let text: String
    let userType: UserType
    var chatTheme: ChatTheme

    var body: some View {
        Text(text)
        .font(.custom("Raleway", size: 12).weight(.medium))
        .lineSpacing(16 - 12)
        .tracking(0)
        .multilineTextAlignment(.trailing)
        .foregroundColor(Color(hex: "#96A2B4"))
    }
}

struct MessageTimeWithCapsuleView: View {

    let text: String
    let isCurrentUser: Bool
    var chatTheme: ChatTheme

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.white)
            .opacity(0.8)
            .padding(.top, 4)
            .padding(.bottom, 4)
            .padding(.horizontal, 8)
            .background {
                Capsule()
                    .foregroundColor(.black.opacity(0.4))
            }
    }
}

