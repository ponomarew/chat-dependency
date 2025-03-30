//
//  MessageMenu+Action.swift
//  Chat
//

import SwiftUI
import ExyteMediaPicker

public protocol MessageMenuAction: Equatable {
    func title() -> String
    func icon() -> Image
    
    static func menuItems(for message: Message) -> [Self]
}

extension MessageMenuAction {
//    public static func menuItems(for message: Message) -> [Self] {
//        Self.allCases.map { $0 }
//    }
}

public enum DefaultMessageMenuAction: MessageMenuAction {

    case copy
    case delete
    case resend

    public func title() -> String {
        switch self {
        case .copy:
            "Копировать"
        case .delete:
            "Удалить сообщение"
        case .resend:
            "Повтоить отправку"
        }
    }

    public func icon() -> Image {
        switch self {
        case .copy:
            Image(systemName: "doc.on.doc")
        case .delete:
            Image(systemName: "arrowshape.turn.up.left")
        case .resend:
            Image(systemName: "bubble.and.pencil")
        }
    }

    public static func == (lhs: DefaultMessageMenuAction, rhs: DefaultMessageMenuAction) -> Bool {
        switch (lhs, rhs) {
        case (.copy, .copy),
             (.delete, .delete),
             (.resend, .resend):
            return true
        default:
            return false
        }
    }
    
    static public func menuItems(for message: Message) -> [DefaultMessageMenuAction] {
        let actions: [DefaultMessageMenuAction]
        
        if message.status == .error(DraftMessage(text: message.text, medias: [], giphyMedia: nil, recording: nil, replyMessage: nil, createdAt: message.createdAt)) {
            actions = [.copy, .delete, .resend]
        } else {
            actions = [.copy, .delete]
        }
        
        return actions
    }
}
