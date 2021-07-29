//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class HackrNewsFeedPresenter {
    public static var topStoriesTitle: String {
        NSLocalizedString(
            "top_stories_title",
            tableName: "HackrNewsFeed",
            bundle: Bundle(for: HackrNewsFeedPresenter.self),
            value: "",
            comment: "Top Stories title view"
        )
    }

    public static var newStoriesTitle: String {
        NSLocalizedString(
            "new_stories_title",
            tableName: "HackrNewsFeed",
            bundle: Bundle(for: HackrNewsFeedPresenter.self),
            value: "",
            comment: "New Stories title view"
        )
    }

    public static var bestStoriesTitle: String {
        NSLocalizedString(
            "best_stories_title",
            tableName: "HackrNewsFeed",
            bundle: Bundle(for: HackrNewsFeedPresenter.self),
            value: "",
            comment: "Best Stories title view"
        )
    }

    private var errorMessage: String {
        NSLocalizedString(
            "new_stories_error_message",
            tableName: "HackrNewsFeed",
            bundle: Bundle(for: HackrNewsFeedPresenter.self),
            value: "",
            comment: "New Stories loading error message"
        )
    }
}
