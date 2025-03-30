//
//  ChatTheme+UserType.swift
//  Chat
//
//  Created by ftp27 on 21.02.2025.
//

import SwiftUI

extension ChatTheme.Colors {
    func messageBG(_ type: UserType) -> Color {
        switch type {
        case .current: Color(hex: "EFF3FD")
        case .other: Color(hex: "FFFFFF")
        case .system: messageSystemBG
        }
    }
    
    func messageText(_ type: UserType) -> Color {
        switch type {
        case .current: Color(hex: "1D1D21")
        case .other: Color(hex: "1D1D21")
        case .system: messageSystemText
        }
    }
    
    func messageTimeText(_ type: UserType) -> Color {
        switch type {
        case .current: Color(hex: "96A2B4")
        case .other: Color(hex: "96A2B4")
        case .system: messageSystemTimeText
        }
    }
}
