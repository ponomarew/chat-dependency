//
//  SwiftUIView.swift
//
//
//  Created by Alisa Mylnikova on 06.12.2023.
//

import SwiftUI

public extension ChatView where MessageContent == EmptyView {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         chatTypeFromRest: ChatTypeFromRest = .user,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         inputViewBuilder: @escaping InputViewBuilderClosure,
         messageMenuAction: MessageMenuActionClosure?) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.inputViewBuilder = inputViewBuilder
        self.messageMenuAction = messageMenuAction
        self.chatTypeFromRest = chatTypeFromRest
    }
}

public extension ChatView where InputViewContent == EmptyView {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         chatTypeFromRest: ChatTypeFromRest = .user,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         messageBuilder: @escaping MessageBuilderClosure,
         messageMenuAction: MessageMenuActionClosure?) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.messageBuilder = messageBuilder
        self.messageMenuAction = messageMenuAction
        self.chatTypeFromRest = chatTypeFromRest
    }
}

public extension ChatView where MenuAction == DefaultMessageMenuAction {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         chatTypeFromRest: ChatTypeFromRest = .user,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         messageBuilder: @escaping MessageBuilderClosure,
         inputViewBuilder: @escaping InputViewBuilderClosure) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.messageBuilder = messageBuilder
        self.inputViewBuilder = inputViewBuilder
        self.chatTypeFromRest = chatTypeFromRest
    }
}

public extension ChatView where MessageContent == EmptyView, InputViewContent == EmptyView {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         chatTypeFromRest: ChatTypeFromRest = .user,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         messageMenuAction: MessageMenuActionClosure?) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.messageMenuAction = messageMenuAction
        self.chatTypeFromRest = chatTypeFromRest
    }
}

public extension ChatView where InputViewContent == EmptyView, MenuAction == DefaultMessageMenuAction {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         chatTypeFromRest: ChatTypeFromRest = .user,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         messageBuilder: @escaping MessageBuilderClosure) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.messageBuilder = messageBuilder
        self.chatTypeFromRest = chatTypeFromRest
    }
}

public extension ChatView where MessageContent == EmptyView, MenuAction == DefaultMessageMenuAction {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         chatTypeFromRest: ChatTypeFromRest = .user,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil,
         inputViewBuilder: @escaping InputViewBuilderClosure) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.inputViewBuilder = inputViewBuilder
        self.chatTypeFromRest = chatTypeFromRest
    }
}

public extension ChatView where MessageContent == EmptyView, InputViewContent == EmptyView, MenuAction == DefaultMessageMenuAction {

    init(messages: [Message],
         chatType: ChatType = .conversation,
         chatTypeFromRest: ChatTypeFromRest = .user,
         replyMode: ReplyMode = .quote,
         didSendMessage: @escaping (DraftMessage) -> Void,
         reactionDelegate: ReactionDelegate? = nil) {
        self.type = chatType
        self.didSendMessage = didSendMessage
        self.reactionDelegate = reactionDelegate
        self.sections = ChatView.mapMessages(messages, chatType: chatType, replyMode: replyMode)
        self.ids = messages.map { $0.id }
        self.chatTypeFromRest = chatTypeFromRest
    }
}
