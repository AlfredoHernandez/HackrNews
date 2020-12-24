//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import HackrNewsApp
import XCTest

final class SceneDelegateTests: XCTestCase {
    func test_configureWindow_setsWindowKeyAndVisible() {
        let window = UIWindow()
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()

        XCTAssertTrue(window.isKeyWindow, "Expected to be key window")
        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }
}
