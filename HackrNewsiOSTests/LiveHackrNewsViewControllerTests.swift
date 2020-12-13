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

    func test_loadLiveHackrNewsCompletion_rendersSuccessfullyLoadedLiveHackrNews() {
        let (sut, loader) = makeSUT()
        let new1 = 1
        let new2 = 2
        let new3 = 3
        let new4 = 4

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeLiveHackrNewsLoading(with: [new1], at: 0)
        assertThat(sut, isRendering: [new1])

        sut.simulateUserInitiatedLiveHackrNewsReload()
        loader.completeLiveHackrNewsLoading(with: [new1, new2, new3, new4], at: 1)
        assertThat(sut, isRendering: [new1, new2, new3, new4])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LiveHackrNewsViewController, LiveHackerNewLoaderSpy) {
        let loader = LiveHackerNewLoaderSpy()
        let sut = LiveHackrNewsViewController(loader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private func assertThat(
        _ sut: LiveHackrNewsViewController,
        hasViewConfiguredFor model: LiveHackerNew,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.liveHackrNewView(for: index)
        guard let cell = view as? LiveHackrNewCell else {
            return XCTFail("Expected \(LiveHackrNewCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        XCTAssertEqual(cell.cellId, model, "Expected to be \(model) id for cell, but got \(cell.cellId) instead.", file: file, line: line)
    }

    private func assertThat(
        _ sut: LiveHackrNewsViewController,
        isRendering liveHackerNews: [LiveHackerNew],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(
            sut.numberOfRenderedLiveHackrNewsViews(),
            liveHackerNews.count,
            "Expected \(liveHackerNews.count) news, got \(sut.numberOfRenderedLiveHackrNewsViews()) instead.",
            file: file,
            line: line
        )
        liveHackerNews.enumerated().forEach { index, new in
            assertThat(sut, hasViewConfiguredFor: new, at: index, file: file, line: line)
        }
    }

    private class LiveHackerNewLoaderSpy: LiveHackrNewsLoader {
        var completions = [(LiveHackrNewsLoader.Result) -> Void]()
        var loadCallCount: Int { completions.count }

        func load(completion: @escaping (LiveHackrNewsLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeLiveHackrNewsLoading(with news: [LiveHackerNew] = [], at index: Int = 0) {
            completions[index](.success(news))
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

    func numberOfRenderedLiveHackrNewsViews() -> Int {
        tableView.numberOfRows(inSection: hackrNewsSection)
    }

    func liveHackrNewView(for row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: hackrNewsSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }

    var hackrNewsSection: Int { 0 }
}

extension LiveHackrNewCell {
    var cellId: Int { id }
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
