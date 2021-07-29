//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class StoryPresentationTests: XCTestCase {
    func test_didFinishLoadingStory_displaysStoryAndStopsLoading() {
        let locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar(identifier: .gregorian)
        let date = Date(timeIntervalSince1970: 1175714200)
        let url = URL(string: "https://any-url.com/a-link.html")!
        let story = Story(
            id: 1,
            title: "a title",
            text: "a text",
            author: "an author",
            score: 2,
            createdAt: date,
            totalComments: 10,
            comments: [1],
            type: "story",
            url: url
        )

        let viewModel = StoryViewModel(
            newId: story.id,
            title: story.title,
            author: story.author,
            comments: localized("story_comments_message", [story.totalComments ?? 0]),
            score: localized("story_points_message", [story.score ?? 0]),
            date: "Apr 04, 2007",
            url: URL(string: "https://any-url.com/a-link.html")!,
            displayURL: "any-url.com"
        )

        let result = StoryPresenter.map(story: story, locale: locale, calendar: calendar)

        XCTAssertEqual(result, viewModel)
    }

    // MARK: - Helpers

    private func localized(_ key: String, _ args: [CVarArg] = [], file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Story"
        let bundle = Bundle(for: StoryPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        return String(format: value, arguments: args)
    }
}
