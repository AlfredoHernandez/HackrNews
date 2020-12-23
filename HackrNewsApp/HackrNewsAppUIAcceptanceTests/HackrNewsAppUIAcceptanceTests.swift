//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class HackrNewsAppUIAcceptanceTests: XCTestCase {
    func test_run_app() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
