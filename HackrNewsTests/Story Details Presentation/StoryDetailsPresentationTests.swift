//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

struct StoryDetailViewModel {
    let title: String
    let author: String
    let score: String
    let comments: String
    let createdAt: String
    let displayURL: String
}

class StoryDetailsPresenter {
    static var title: String {
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

    static func map(
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
            displayURL: story.url.host ?? ""
        )
    }
}

final class StoryDetailsPresentationTests: XCTestCase {
    func test_storyDetailsTitle_isLocalized() {
        XCTAssertEqual(StoryDetailsPresenter.title, localized("story_details_title"))
    }

    func test_map_createViewModel() {
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let oneDayAgo = Date().adding(days: -1)
        let story = StoryDetail(
            title: "a title",
            author: "an author",
            score: 10,
            createdAt: oneDayAgo,
            totalComments: 1,
            comments: [1],
            url: anyURL()
        )

        let viewModel = StoryDetailsPresenter.map(story, calendar: calendar, locale: locale)

        XCTAssertEqual(viewModel.title, story.title)
        XCTAssertEqual(viewModel.author, story.author)
        XCTAssertEqual(viewModel.score, "10 points")
        XCTAssertEqual(viewModel.comments, "1 comments")
        XCTAssertEqual(viewModel.createdAt, "1 day ago")
        XCTAssertEqual(viewModel.displayURL, "any-url.com")
    }

    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "StoryDetails"
        let bundle = Bundle(for: StoryDetailsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
}
