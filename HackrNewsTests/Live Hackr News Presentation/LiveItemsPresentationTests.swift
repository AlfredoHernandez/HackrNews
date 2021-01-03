//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class LiveItemsPresenter {
    static let title = ""
}

final class NewStoriesPresentationTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(LiveItemsPresenter.title, localized("live_items_title"))
    }

    // MARK: - Helpers

    private func localized(_ key: String, file _: StaticString = #filePath, line _: UInt = #line) -> String {
        let table = "LiveItems"
        let bundle = Bundle(for: NewStoriesPresentationTests.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)")
        }
        return value
    }
}
