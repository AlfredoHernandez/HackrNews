//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import HackrNewsApp
import HackrNewsiOS
import XCTest

final class SceneDelegateTests: XCTestCase {
    func test_configureWindow_setsWindowKeyAndVisible() {
        let window = UIWindowSpy()
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()

        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1, "Expected to make window key and visible")
    }

    func test_configureWindow_configuresRootViewController() {
        let window = UIWindow()
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()

        let rootViewController = window.rootViewController as? UITabBarController

        XCTAssertNotNil(rootViewController, "Expected a TabBarController, but got \(String(describing: rootViewController))")

        let firstNavController = rootViewController?.viewControllers?.first as? UINavigationController
        XCTAssertNotNil(
            firstNavController,
            "Expected a navigation controller for first controller, but got \(String(describing: firstNavController))"
        )

        let firstController = firstNavController?.topViewController
        XCTAssertNotNil(
            firstController as? HackrNewsFeedViewController,
            "Expected a `\(String(describing: HackrNewsFeedViewController.self))` as first item on tab bar, got \(String(describing: firstController))"
        )
    }

    // MARK: - Helpers

    private class UIWindowSpy: UIWindow {
        var makeKeyAndVisibleCallCount = 0

        override func makeKeyAndVisible() {
            makeKeyAndVisibleCallCount = 1
        }
    }
}
