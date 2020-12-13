//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit
import XCTest

class StoriesViewController: UITableViewController {
    private var loader: LiveHackrNewsLoader?

    convenience init(loader: LiveHackrNewsLoader) {
        self.init()
        self.loader = loader
    }

    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }

    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
}

final class StoriesViewControllerTests: XCTestCase {
    func test_loadStoriesActions_requestStoriesLoader() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)

        sut.simulateUserInitiatedStoriesReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulateUserInitiatedStoriesReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    func test_loadingStoriesIndicator_isVisibleWhileLoadingStories() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeStoriesLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserInitiatedStoriesReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeStoriesLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (StoriesViewController, LiveHackerNewLoaderSpy) {
        let loader = LiveHackerNewLoaderSpy()
        let sut = StoriesViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private class LiveHackerNewLoaderSpy: LiveHackrNewsLoader {
        var completions = [(LiveHackrNewsLoader.Result) -> Void]()
        var loadCallCount: Int { completions.count }

        func load(completion: @escaping (LiveHackrNewsLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeStoriesLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

extension StoriesViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    func simulateUserInitiatedStoriesReload() {
        refreshControl?.simulatePullToRefresh()
    }
}

extension UIControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { selector in
                (target as NSObject).perform(Selector(selector))
            }
        }
    }
}
