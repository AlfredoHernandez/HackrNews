//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class HackrNewsFeedPresentationTests: XCTestCase {
    func test_topStoriesTitle_isLocalized() {
        XCTAssertEqual(HackrNewsFeedPresenter.topStoriesTitle, localized("top_stories_title"))
    }

    func test_newStoriesTitle_isLocalized() {
        XCTAssertEqual(HackrNewsFeedPresenter.newStoriesTitle, localized("new_stories_title"))
    }

    func test_bestStoriesTitle_isLocalized() {
        XCTAssertEqual(HackrNewsFeedPresenter.bestStoriesTitle, localized("best_stories_title"))
    }

    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "HackrNewsFeed"
        let bundle = Bundle(for: HackrNewsFeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
}
