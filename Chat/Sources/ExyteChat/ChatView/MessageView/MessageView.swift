//
//  MessageView.swift
//  Chat
//
//  Created by Alex.M on 23.05.2022.
//

import SwiftUI

struct MessageView: View {

    @Environment(\.chatTheme) var theme

    @ObservedObject var viewModel: ChatViewModel

    let message: Message
    let positionInUserGroup: PositionInUserGroup
    let positionInMessagesSection: PositionInMessagesSection
    let chatType: ChatType
    let avatarSize: CGFloat
    let tapAvatarClosure: ChatView.TapAvatarClosure?
    let messageStyler: (String) -> AttributedString
    let isDisplayingMessageMenu: Bool
    let showMessageTimeView: Bool
    var font: UIFont

    @State var avatarViewSize: CGSize = .zero
    @State var statusSize: CGSize = .zero
    @State var timeSize: CGSize = .zero
    @State var messageSize: CGSize = .zero
    
    // The size of our reaction bubbles are based on the users font size,
    // Therefore we need to capture it's rendered size in order to place it correctly
    @State var bubbleSize: CGSize = .zero
    
    static let widthWithMedia: CGFloat = 204
    static let horizontalNoAvatarPadding: CGFloat = 8
    static let horizontalAvatarPadding: CGFloat = 8
    static let horizontalTextPadding: CGFloat = 12
    static let horizontalAttachmentPadding: CGFloat = 1 // for multiple attachments
    static let statusViewSize: CGFloat = 16
    static let horizontalStatusPadding: CGFloat = 8
    static let horizontalBubblePadding: CGFloat = 70

    enum DateArrangement {
        case hstack, vstack, overlay
    }

    var additionalMediaInset: CGFloat {
        message.attachments.count > 1 ? MessageView.horizontalAttachmentPadding * 2 : 0
    }

    var dateArrangement: DateArrangement {
        let timeWidth = timeSize.width + 10
        let textPaddings = MessageView.horizontalTextPadding * 2
        let widthWithoutMedia = UIScreen.main.bounds.width
        - (message.user.isCurrentUser ? MessageView.horizontalNoAvatarPadding : avatarViewSize.width)
        - statusSize.width
        - MessageView.horizontalBubblePadding
        - textPaddings

        let maxWidth = message.attachments.isEmpty ? widthWithoutMedia : MessageView.widthWithMedia - textPaddings
        let styledText = message.text.styled(using: messageStyler)

        let finalWidth = styledText.width(withConstrainedWidth: maxWidth, font: font)
        let lastLineWidth = styledText.lastLineWidth(labelWidth: maxWidth, font: font)
        let numberOfLines = styledText.numberOfLines(labelWidth: maxWidth, font: font)

        if numberOfLines == 1, finalWidth + CGFloat(timeWidth) < maxWidth {
            return .hstack
        }
        if lastLineWidth + CGFloat(timeWidth) < finalWidth {
            return .vstack
        }
        return .vstack
    }

    var showAvatar: Bool {
        isDisplayingMessageMenu
        || positionInUserGroup == .single
        || (chatType == .conversation && positionInUserGroup == .last)
        || (chatType == .comments && positionInUserGroup == .first)
    }

    var topPadding: CGFloat {
        let bubbleOffset = message.reactions.isEmpty ? 0 : bubbleSize.height / 1.5
        if chatType == .comments { return bubbleOffset }
        var amount: CGFloat = positionInUserGroup.isTop && !positionInMessagesSection.isTop ? 8 : 4
        if !message.reactions.isEmpty { amount += bubbleOffset }
        return amount
    }

    var bottomPadding: CGFloat {
        if chatType == .conversation { return 0 }
        return positionInUserGroup.isTop ? 8 : 4
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
//            if !message.user.isCurrentUser {
//                avatarView
//            }

            VStack(alignment: message.user.isCurrentUser ? .trailing : .leading, spacing: 2) {
                if !isDisplayingMessageMenu, let reply = message.replyMessage?.toMessage() {
                    replyBubbleView(reply)
                        .opacity(theme.style.replyOpacity)
                        .padding(message.user.isCurrentUser ? .trailing : .leading, 10)
                        .overlay(alignment: message.user.isCurrentUser ? .trailing : .leading) {
                            Capsule()
                                .foregroundColor(theme.colors.mainTint)
                                .frame(width: 2)
                        }
                }

                bubbleView(message)
                    .shadow(color: Color(hex: "#003350").opacity(0.06), radius: 16, x: 0, y: 4)
            }
        }
        
        .padding(.leading, message.user.isCurrentUser ? 0 : 16)
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .padding(.trailing, message.user.isCurrentUser ? 16 : 0)
        .padding(message.user.isCurrentUser ? .leading : .trailing, MessageView.horizontalBubblePadding)
        .frame(maxWidth: UIScreen.main.bounds.width, alignment: message.user.isCurrentUser ? .trailing : .leading)
    }

    @ViewBuilder
    func bubbleView(_ message: Message) -> some View {
        ZStack(alignment: message.user.isCurrentUser ? .topLeading : .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                if !message.attachments.isEmpty {
                    attachmentsView(message)
                }
                
                if !message.text.isEmpty {
                    textWithTimeView(message)
                        .font(Font(font))
                }
            }
            .bubbleBackground(message, theme: theme)
            .applyIf(isDisplayingMessageMenu) {
                $0.frameGetter($viewModel.messageFrame)
            }
            
            if !isDisplayingMessageMenu && !message.reactions.isEmpty {
                reactionsView(message)
            }
        }
    }

    @ViewBuilder
    func replyBubbleView(_ message: Message) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(message.user.name)
                .fontWeight(.semibold)
                .padding(.horizontal, MessageView.horizontalTextPadding)

            if !message.attachments.isEmpty {
                attachmentsView(message)
                    .padding(.top, 4)
                    .padding(.bottom, message.text.isEmpty ? 0 : 4)
            }

            if !message.text.isEmpty {
                MessageTextView(
                    text: message.text, messageStyler: messageStyler,
                    userType: message.user.type
                )
                .padding(.horizontal, MessageView.horizontalTextPadding)
            }

            if let recording = message.recording {
                recordingView(recording)
            }
        }
        .font(.caption2)
        .padding(.vertical, 8)
        .frame(width: message.attachments.isEmpty ? nil : MessageView.widthWithMedia + additionalMediaInset)
        .bubbleBackground(message, theme: theme, isReply: true)
    }

    @ViewBuilder
    var avatarView: some View {
        Group {
            if showAvatar {
                AvatarView(url: message.user.avatarURL, avatarSize: avatarSize)
                    .contentShape(Circle())
                    .onTapGesture {
                        tapAvatarClosure?(message.user, message.id)
                    }
            } else {
                Color.clear.viewSize(avatarSize)
            }
        }
        .padding(.horizontal, MessageView.horizontalAvatarPadding)
        .sizeGetter($avatarViewSize)
    }

    @ViewBuilder
    func attachmentsView(_ message: Message) -> some View {
        AttachmentsGrid(attachments: message.attachments) {
            viewModel.presentAttachmentFullScreen($0)
        }
        .applyIf(message.attachments.count > 1) {
            $0
                .padding(.top, MessageView.horizontalAttachmentPadding)
                .padding(.horizontal, MessageView.horizontalAttachmentPadding)
        }
        .overlay(alignment: .bottomTrailing) {
            if message.text.isEmpty {
                messageTimeView()
                    .padding(4)
            }
        }
        .contentShape(Rectangle())
    }

    @ViewBuilder
    func textWithTimeView(_ message: Message) -> some View {
        let messageView = MessageTextView(
            text: message.text, messageStyler: messageStyler,
            userType: message.user.type
        )
        .fixedSize(horizontal: false, vertical: false)

        let timeView = messageTimeView()

        Group {
            switch dateArrangement {
            case .hstack:
                HStack(alignment: .center, spacing: 4) {
                    messageView
                        .frame(minWidth: 0, maxWidth: .none, alignment: .leading)
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: 1, height: 1)
                    
                    if !message.attachments.isEmpty {
                        Spacer()
                    }
                    timeView
                        .padding(.trailing, message.user.isCurrentUser ? 0 : 0)

//                    if message.user.isCurrentUser, let status = message.status {
//                        MessageStatusView(status: status) {
//                            if case let .error(draft) = status {
//                                viewModel.sendMessage(draft)
//                            }
//                        }
//                        .frame(width: 16, height: 16)
//                        .sizeGetter($statusSize)
//                    }
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            case .vstack:
                VStack(alignment: .leading, spacing: 4) {
                    messageView
//                        .padding(.trailing, 20)
                    HStack(spacing: 0) {
                        Spacer()
                        timeView
                            .padding(.trailing, message.user.isCurrentUser ? 0 : 0)
                        
//                        if message.user.isCurrentUser, let status = message.status {
//                            MessageStatusView(status: status) {
//                                if case let .error(draft) = status {
//                                    viewModel.sendMessage(draft)
//                                }
//                            }
//                            .frame(width: 16, height: 16)
////                            .padding(.trailing, 20)
//                            .sizeGetter($statusSize)
//                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            case .overlay:
                messageView
                    .padding(.vertical, 8)
                    .overlay(alignment: .bottomTrailing) {
                        timeView
                            .padding(.vertical, 8)
                    }
            }
        }
    }

    @ViewBuilder
    func recordingView(_ recording: Recording) -> some View {
        RecordWaveformWithButtons(
            recording: recording,
            colorButton: message.user.isCurrentUser ? theme.colors.messageMyBG : theme.colors.mainBG,
            colorButtonBg: message.user.isCurrentUser ? theme.colors.mainBG : theme.colors.messageMyBG,
            colorWaveform: theme.colors.messageText(message.user.type)
        )
        .padding(.horizontal, MessageView.horizontalTextPadding)
        .padding(.top, 8)
    }

    func messageTimeView() -> some View {
        Group {
            if showMessageTimeView {
                HStack {
                    MessageTimeView(text: message.time, userType: message.user.type, chatTheme: theme)
                    
                }
            }
        }
        .sizeGetter($timeSize)
    }
}

extension View {

    @ViewBuilder
    func bubbleBackground(_ message: Message, theme: ChatTheme, isReply: Bool = false) -> some View {
        let radius: CGFloat = !message.attachments.isEmpty ? 8 : 16
        let additionalMediaInset: CGFloat = message.attachments.count > 1 ? 2 : 0
        self
            .frame(width: message.attachments.isEmpty ? nil : MessageView.widthWithMedia + additionalMediaInset)
            .foregroundColor(theme.colors.messageText(message.user.type))
            .background {
                if isReply || !message.text.isEmpty || message.recording != nil {
                    Rectangle()
                        .foregroundColor(theme.colors.messageBG(message.user.type))
                        .opacity(isReply ? theme.style.replyOpacity : 1)
                        .roundedCorner(
                            radius, corners: message.user.type == .current ?
                                [.topLeft, .bottomLeft, .bottomRight] :
                                [.topRight, .bottomLeft, .bottomRight]
                        )
                }
            }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

public extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

#if DEBUG
struct MessageView_Preview: PreviewProvider {
    static let stan = User(id: "stan", name: "Stan", avatarURL: nil, isCurrentUser: false)
    static let john = User(id: "john", name: "John", avatarURL: nil, isCurrentUser: true)

    static private var shortMessage = "Joefsasdey"
    static private var longMessage = "Hello hello sf e fe sda sdfdsaf sadc"

    static private var replyedMessage = Message(
        id: UUID().uuidString,
        user: stan,
        status: .read,
        createdAt: "2025-03-13T04:46:29.448Z".toDateFromISO8601() ?? Date(),
        text: shortMessage,
        attachments: [
//            Attachment.randomImage(),
//            Attachment.randomImage(),
//            Attachment.randomImage(),
//            Attachment.randomImage(),
//            Attachment.randomImage(),
        ],
        reactions: []
    )

    static private var message = Message(
        id: UUID().uuidString,
        user: stan,
        status: .read,
        text: shortMessage,
        replyMessage: replyedMessage.toReplyMessage()
    )

    static var previews: some View {
        ZStack {
            Color.yellow.ignoresSafeArea()

            MessageView(
                viewModel: ChatViewModel(),
                message: replyedMessage,
                positionInUserGroup: .single,
                positionInMessagesSection: .single,
                chatType: .conversation,
                avatarSize: 32,
                tapAvatarClosure: nil,
                messageStyler: AttributedString.init,
                isDisplayingMessageMenu: false,
                showMessageTimeView: true,
                font: UIFontMetrics.default.scaledFont(for: UIFont.systemFont(ofSize: 16))
            )
        }
    }
}
#endif
