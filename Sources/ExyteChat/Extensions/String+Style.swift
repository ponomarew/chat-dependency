//
//  String+Style.swift
//  Chat
//
//  Created by Matthew Fennell on 01/03/2025.
//

import Foundation

extension String {

    private static var markdownOptions = AttributedString.MarkdownParsingOptions(
        allowsExtendedAttributes: false,
        interpretedSyntax: .inlineOnlyPreservingWhitespace,
        failurePolicy: .returnPartiallyParsedIfPossible,
        languageCode: nil
    )

    public static func markdownStyler(text: String) -> AttributedString {
        if let attributed = try? AttributedString(markdown: text, options: String.markdownOptions) {
            attributed
        } else {
            AttributedString(stringLiteral: text)
        }
    }

    public func styled(using styler: (String) -> AttributedString) -> AttributedString {
        styler(self)
    }

    public func toDateFromISO8601() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Handles milliseconds
        return formatter.date(from: self)
    }
}
