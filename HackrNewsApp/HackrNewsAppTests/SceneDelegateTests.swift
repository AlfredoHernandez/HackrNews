//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import HackrNewsApp
import HackrNewsiOS
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

    func test_configureWindow_configuresRootViewController() {
        let window = UIWindow()
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()

        let rootViewController = window.rootViewController as? UITabBarController

        XCTAssertNotNil(rootViewController, "Expected a TabBarController, but got \(String(describing: rootViewController))")

        let firstController = rootViewController?.viewControllers?.first
        XCTAssertNotNil(
            firstController as? LiveHackrNewsViewController,
            "Expected a `LiveHackrNewsViewController` as first item on tab bar, got \(String(describing: firstController))"
        )
    }
}
