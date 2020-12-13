//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import XCTest

final class LiveHackrNewsViewControllerTests: XCTestCase {
    func test_loadLiveHackrNewsActions_requestLiveHackrNewsLoader() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)

        sut.simulateUserInitiatedLiveHackrNewsReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulateUserInitiatedLiveHackrNewsReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    func test_loadingLiveHackrNewsIndicator_isVisibleWhileLoadingLiveHackrNews() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeLiveHackrNewsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)

        sut.simulateUserInitiatedLiveHackrNewsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)

        loader.completeLiveHackrNewsLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LiveHackrNewsViewController, LiveHackerNewLoaderSpy) {
        let loader = LiveHackerNewLoaderSpy()
        let sut = LiveHackrNewsViewController(loader: loader)
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

        func completeLiveHackrNewsLoading(at index: Int = 0) {
            completions[index](.success([]))
        }
    }
}

extension LiveHackrNewsViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    func simulateUserInitiatedLiveHackrNewsReload() {
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
