//
//  Created by Alex.M on 20.06.2022.
//

import Foundation
import Combine
import UIKit

final class ChatViewModel: ObservableObject {

    @Published private(set) var fullscreenAttachmentItem: Optional<Attachment> = nil
    @Published var fullscreenAttachmentPresented = false

    @Published var messageMenuRow: MessageRow?
    
    /// The messages frame that is currently being rendered in the Message Menu
    /// - Note: Used to further refine a messages frame (instead of using the cell boundary), mainly used for positioning reactions
    @Published var messageFrame: CGRect = .zero
    
    /// Provides a mechanism to issue haptic feedback to the user
    /// - Note: Used when launching the MessageMenu
    let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    let inputFieldId = UUID()

    var didSendMessage: (DraftMessage) -> Void = {_ in}
    var inputViewModel: InputViewModel?
    var globalFocusState: GlobalFocusState?

    func presentAttachmentFullScreen(_ attachment: Attachment) {
        fullscreenAttachmentItem = attachment
        fullscreenAttachmentPresented = true
    }
    
    func dismissAttachmentFullScreen() {
        fullscreenAttachmentPresented = false
        fullscreenAttachmentItem = nil
    }

    func sendMessage(_ message: DraftMessage) {
        didSendMessage(message)
    }

    func messageMenuAction() -> (Message, DefaultMessageMenuAction) -> Void {
        { [weak self] message, action in
            DispatchQueue.main.async {
                self?.messageMenuActionInternal(message: message, action: action)
            }
        }
    }

    @MainActor
    func messageMenuActionInternal(message: Message, action: DefaultMessageMenuAction) {
        switch action {
        case .copy:
            UIPasteboard.general.string = message.text
        default:
            break
        }
    }
}
