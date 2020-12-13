//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class StoriesViewController {
    init(loader _: LiveHackrNewsLoader) {}
}

final class StoriesViewControllerTests: XCTestCase {
    func test_init_doesNotLoadStories() {
        let loader = LiveHackerNewLoaderSpy()
        _ = StoriesViewController(loader: loader)

        XCTAssertEqual(loader.loadCallCount, 0)
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
