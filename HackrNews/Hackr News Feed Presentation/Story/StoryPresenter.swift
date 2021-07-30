//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryViewModel: Equatable {
    public let newId: Int
    public let title: String?
    public let author: String?
    public let comments: String?
    public let score: String?
    public let date: String?
    public let url: URL?
    public let displayURL: String?

    public init(
        newId: Int,
        title: String?,
        author: String?,
        comments: String?,
        score: String?,
        date: String?,
        url: URL?,
        displayURL: String?
    ) {
        self.newId = newId
        self.title = title
        self.author = author
        self.comments = comments
        self.score = score
        self.date = date
        self.url = url
        self.displayURL = displayURL
    }
}

public final class StoryPresenter {
    private static var comments: String {
        NSLocalizedString(
            "story_comments_message",
            tableName: "Story",
            bundle: Bundle(for: StoryPresenter.self),
            value: "",
            comment: "Story comments text label"
        )
    }

    private static var score: String {
        NSLocalizedString(
            "story_points_message",
            tableName: "Story",
            bundle: Bundle(for: StoryPresenter.self),
            value: "",
            comment: "Story score text label"
        )
    }

    public static func map(story: Story, locale: Locale = Locale.current, calendar: Calendar = Calendar(identifier: .gregorian)) -> StoryViewModel {
        StoryViewModel(
            newId: story.id,
            title: story.title,
            author: story.author,
            comments: String(format: comments, story.totalComments ?? 0),
            score: String(format: score, story.score ?? "0"),
            date: format(from: story.createdAt, locale: locale, calendar: calendar),
            url: story.url,
            displayURL: story.url?.host
        )
    }

    private static func format(from date: Date, locale: Locale = Locale.current, calendar: Calendar = Calendar(identifier: .gregorian)) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
}
