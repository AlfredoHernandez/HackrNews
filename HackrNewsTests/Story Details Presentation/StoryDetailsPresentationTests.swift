//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

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
}

final class StoryDetailsPresentationTests: XCTestCase {
    func test_storyDetailsTitle_isLocalized() {
        XCTAssertEqual(StoryDetailsPresenter.title, localized("story_details_title"))
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
