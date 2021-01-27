//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

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
