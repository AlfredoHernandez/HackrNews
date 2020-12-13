//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit
import XCTest

class StoriesViewController: UIViewController {
    private var loader: LiveHackrNewsLoader?

    convenience init(loader: LiveHackrNewsLoader) {
        self.init()
        self.loader = loader
    }

    override func viewDidLoad() {
        loader?.load { _ in
        }
    }
}

final class StoriesViewControllerTests: XCTestCase {
    func test_init_doesNotLoadStories() {
        let loader = LiveHackerNewLoaderSpy()
        _ = StoriesViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsStories() {
        let loader = LiveHackerNewLoaderSpy()
        let sut = StoriesViewController(loader: loader)

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    // MARK: - Helpers

    private class LiveHackerNewLoaderSpy: LiveHackrNewsLoader {
        var completions = [(LiveHackrNewsLoader.Result) -> Void]()
        var loadCallCount: Int { completions.count }

        func load(completion: @escaping (LiveHackrNewsLoader.Result) -> Void) {
            completions.append(completion)
        }
    }
}
