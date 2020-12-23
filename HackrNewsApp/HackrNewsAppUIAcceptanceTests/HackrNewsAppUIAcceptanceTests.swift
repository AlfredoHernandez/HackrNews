//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class HackrNewsAppUIAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteStoriesWhenCustomerHasConnectivity() {
        let app = XCUIApplication()

        app.launch()

        let cells = app.cells.matching(identifier: "story-cell")
        XCTAssertLessThanOrEqual(cells.count, 500)

        let storyTitle = cells.firstMatch.staticTexts.matching(identifier: "story-title-cell").firstMatch
        XCTAssertTrue(storyTitle.exists)
    }
}
