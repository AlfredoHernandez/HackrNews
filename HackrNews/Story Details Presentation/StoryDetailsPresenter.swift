//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryDetailViewModel {
    public let title: String?
    public let author: String
    public let score: String?
    public let comments: String?
    public let createdAt: String
    public let displayURL: String?

    public init(title: String?, author: String, score: String?, comments: String?, createdAt: String, displayURL: String?) {
        self.title = title
        self.author = author
        self.score = score
        self.comments = comments
        self.createdAt = createdAt
        self.displayURL = displayURL
    }
}

public class StoryDetailsPresenter {
    public static var title: String {
        NSLocalizedString(
            "story_details_title",
            tableName: "StoryDetails",
            bundle: Bundle(for: StoryDetailsPresenter.self),
            value: "",
            comment: "Story details view title"
        )
    }

    private static var score: String {
        NSLocalizedString(
            "story_details_score",
            tableName: "StoryDetails",
            bundle: Bundle(for: StoryDetailsPresenter.self),
            value: "",
            comment: "StoryDetails score text label"
        )
    }

    private static var comments: String {
        NSLocalizedString(
            "story_details_comments",
            tableName: "StoryDetails",
            bundle: Bundle(for: StoryDetailsPresenter.self),
            value: "",
            comment: "StoryDetails comments text label"
        )
    }

    public static func map(
        _ story: StoryDetail,
        calendar: Calendar = Calendar(identifier: .gregorian),
        locale: Locale = .current
    ) -> StoryDetailViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale

        return StoryDetailViewModel(
            title: story.title,
            author: story.author,
            score: (story.score != nil) ? String(format: score, story.score!) : nil,
            comments: (story.comments != nil) ? String(format: comments, story.totalComments!) : nil,
            createdAt: formatter.localizedString(for: story.createdAt, relativeTo: Date()),
            displayURL: story.url?.host
        )
    }
}
