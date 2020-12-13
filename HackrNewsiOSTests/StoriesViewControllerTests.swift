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
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }

    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }
}

final class StoriesViewControllerTests: XCTestCase {
    func test_init_doesNotLoadStories() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsStories() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_userInitiatedStoriesReload_loadsStories() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        sut.simulateUserInitiatedStoriesReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulateUserInitiatedStoriesReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }

    func test_viewDidLoad_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        loader.completeStoriesLoading()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }

    func test_userInitiatedStoriesReload_showLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.simulateUserInitiatedStoriesReload()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }

    func test_userInitiatedStoriesReload_hidesLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()

        sut.simulateUserInitiatedStoriesReload()
        loader.completeStoriesLoading()

        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
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