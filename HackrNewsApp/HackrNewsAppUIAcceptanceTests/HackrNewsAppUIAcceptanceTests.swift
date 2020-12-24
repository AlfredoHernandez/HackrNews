//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class HackrNewsAppUIAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteStoriesWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-connectivity", "online"]
        app.launch()

        let cells = app.cells.matching(identifier: "story-cell")
        XCTAssertEqual(cells.count, 5)

        let storyTitle = cells.firstMatch.staticTexts.matching(identifier: "story-title-cell").firstMatch
        XCTAssertTrue(storyTitle.exists)
    }

    func test_onLaunch_doesNotDisplayRemoteStoriesWhenCustomerHasNotConnectivity() {
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]

        offlineApp.launch()

        let cells = offlineApp.cells.matching(identifier: "story-cell")
        XCTAssertEqual(cells.count, 0)
    }
}
