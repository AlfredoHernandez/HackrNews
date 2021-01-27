//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryDetailViewModel {
    public let title: String
    public let author: String
    public let score: String
    public let comments: String
    public let createdAt: String
    public let displayURL: String
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
            score: String(format: score, story.score),
            comments: String(format: comments, story.totalComments),
            createdAt: formatter.localizedString(for: story.createdAt, relativeTo: Date()),
            displayURL: story.url.host ?? story.url.absoluteString
        )
    }
}
