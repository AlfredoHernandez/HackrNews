//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct CommentViewModel: Equatable {
    public let author: String
    public let text: String?
    public let createdAt: String

    public init(author: String, text: String?, createdAt: String) {
        self.author = author
        self.text = text
        self.createdAt = createdAt
    }
}

public class CommentPresenter {
    let errorMessage =
        NSLocalizedString(
            "loading_comment_error_message",
            tableName: "StoryDetails",
            bundle: Bundle(for: StoryDetailsPresenter.self),
            value: "",
            comment: "Comment loading error message"
        )

    public static let commentDeleted =
        NSLocalizedString(
            "story_details_comment_deleted",
            tableName: "StoryDetails",
            bundle: Bundle(for: StoryDetailsPresenter.self),
            value: "",
            comment: "Comment deleted message"
        )

    public static func map(
        _ comment: StoryComment,
        against: Date = Date(),
        calendar: Calendar = Calendar(identifier: .gregorian),
        locale: Locale = .current
    ) -> CommentViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        return CommentViewModel(
            author: comment.author ?? commentDeleted,
            text: comment.text,
            createdAt: formatter.localizedString(for: comment.createdAt, relativeTo: against)
        )
    }
}
