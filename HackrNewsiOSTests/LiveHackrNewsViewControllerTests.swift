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

        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected show loading indicator once view is loaded")

        loader.completeLiveHackrNewsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes successfully")

        sut.simulateUserInitiatedLiveHackrNewsReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected show loading indicator once user initiated loading")

        loader.completeLiveHackrNewsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadLiveHackrNewsCompletion_rendersSuccessfullyLoadedLiveHackrNews() {
        let (sut, loader) = makeSUT()
        let new1 = makeLiveHackrNew(id: 1)
        let new2 = makeLiveHackrNew(id: 2)
        let new3 = makeLiveHackrNew(id: 3)
        let new4 = makeLiveHackrNew(id: 4)

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeLiveHackrNewsLoading(with: [new1], at: 0)
        assertThat(sut, isRendering: [new1])

        sut.simulateUserInitiatedLiveHackrNewsReload()
        loader.completeLiveHackrNewsLoading(with: [new1, new2, new3, new4], at: 1)
        assertThat(sut, isRendering: [new1, new2, new3, new4])
    }

    func test_loadLiveHackrNewsCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (sut, loader) = makeSUT()
        let new1 = makeLiveHackrNew(id: 1)

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [new1], at: 0)
        assertThat(sut, isRendering: [new1])

        sut.simulateUserInitiatedLiveHackrNewsReload()
        loader.completeLiveHackrNewsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [new1])
    }

    func test_liveHackrNewView_loadsStoryURLWhenVisible() {
        let (sut, loader) = makeSUT()
        let new1 = makeLiveHackrNew(id: 1, url: URL(string: "https://any-url.com/1.json")!)
        let new2 = makeLiveHackrNew(id: 2, url: URL(string: "https://any-url.com/2.json")!)

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [new1, new2], at: 0)

        XCTAssertEqual(loader.loadedStoryUrls, [], "Expected no story URL requests until views become visible")

        sut.simulateStoryViewVisible(at: 0)
        XCTAssertEqual(loader.loadedStoryUrls, [new1.url], "Expected first story URL request once first view becomes visible")

        sut.simulateStoryViewVisible(at: 1)
        XCTAssertEqual(
            loader.loadedStoryUrls,
            [new1.url, new2.url],
            "Expected second story URL request once second view also becomes visible"
        )
    }

    func test_liveHackrNewView_cancelsStoryLoadingWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let new1 = makeLiveHackrNew(id: 1, url: URL(string: "https://any-url.com/1.json")!)
        let new2 = makeLiveHackrNew(id: 2, url: URL(string: "https://any-url.com/2.json")!)

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [new1, new2], at: 0)

        XCTAssertEqual(loader.cancelledStoryUrls, [], "Expected no cancelled story URL requests until views become visible")

        sut.simulateStoryViewNotVisible(at: 0)
        XCTAssertEqual(
            loader.cancelledStoryUrls,
            [new1.url],
            "Expected first story URL request cancelled once first view becomes not visible"
        )

        sut.simulateStoryViewNotVisible(at: 1)
        XCTAssertEqual(
            loader.cancelledStoryUrls,
            [new1.url, new2.url],
            "Expected second story URL request cancelled once second view also becomes not visible"
        )
    }

    func test_liveHackrNewViewLoadingIndicator_isVisibleWhileLoading() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [makeLiveHackrNew(), makeLiveHackrNew()], at: 0)

        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)

        XCTAssertEqual(view0?.isShowingLoadingIndicator, true, "Expected loading indicator for view0 while loading content")
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true, "Expected loading indicator for view1 while loading content")

        loader.completeStoryLoading(at: 0)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, true)

        loader.completeStoryLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingLoadingIndicator, false)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LiveHackrNewsViewController, LiveHackerNewLoaderSpy) {
        let loader = LiveHackerNewLoaderSpy()
        let sut = LiveHackrNewsViewController(loader: loader, hackrStoryLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private func assertThat(
        _ sut: LiveHackrNewsViewController,
        hasViewConfiguredFor model: LiveHackrNew,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.liveHackrNewView(for: index)
        guard let cell = view as? LiveHackrNewCell else {
            return XCTFail("Expected \(LiveHackrNewCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        XCTAssertEqual(
            cell.cellId,
            model.id,
            "Expected to be \(model.id) id for cell, but got \(cell.cellId) instead.",
            file: file,
            line: line
        )
    }

    private func assertThat(
        _ sut: LiveHackrNewsViewController,
        isRendering liveHackerNews: [LiveHackrNew],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedLiveHackrNewsViews() == liveHackerNews.count else {
            return XCTFail(
                "Expected \(liveHackerNews.count) news, got \(sut.numberOfRenderedLiveHackrNewsViews()) instead.",
                file: file,
                line: line
            )
        }
        liveHackerNews.enumerated().forEach { index, new in
            assertThat(sut, hasViewConfiguredFor: new, at: index, file: file, line: line)
        }
    }

    private func makeLiveHackrNew(id: Int = Int.random(in: 0 ... 100), url: URL = URL(string: "https://any-url.com")!) -> LiveHackrNew {
        LiveHackrNew(id: id, url: url)
    }

    private class LiveHackerNewLoaderSpy: LiveHackrNewsLoader, HackrStoryLoader {
        var completions = [(LiveHackrNewsLoader.Result) -> Void]()
        var loadCallCount: Int { completions.count }

        func load(completion: @escaping (LiveHackrNewsLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeLiveHackrNewsLoading(with news: [LiveHackrNew] = [], at index: Int = 0) {
            completions[index](.success(news))
        }

        func completeLiveHackrNewsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            completions[index](.failure(error))
        }

        // MARK: - HackrStoryLoader

        var loadedStoryUrls: [URL] {
            storiesRequests.map(\.url)
        }

        var cancelledStoryUrls = [URL]()
        var storiesRequests = [(url: URL, completion: (HackrStoryLoader.Result) -> Void)]()

        private struct TaskSpy: HackrStoryLoaderTask {
            let cancellCallback: () -> Void

            func cancel() {
                cancellCallback()
            }
        }

        func load(from url: URL, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
            storiesRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledStoryUrls.append(url) }
        }

        func completeStoryLoading(with story: Story = Story.any, at index: Int = 0) {
            storiesRequests[index].completion(.success(story))
        }

        func completeStoryLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            storiesRequests[index].completion(.failure(error))
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

    @discardableResult
    func simulateStoryViewVisible(at index: Int) -> LiveHackrNewCell? {
        liveHackrNewView(for: index) as? LiveHackrNewCell
    }

    func simulateStoryViewNotVisible(at index: Int) {
        let view = simulateStoryViewVisible(at: index)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: hackrNewsSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }

    var hackrNewsSection: Int { 0 }
}

extension LiveHackrNewCell {
    var cellId: Int { id }

    var isShowingLoadingIndicator: Bool {
        container.isShimmering
    }
}

extension Story {
    static var any = Story(
        id: Int.random(in: 0 ... 100),
        title: "a title",
        author: "a username",
        score: 0,
        createdAt: Date(),
        totalComments: 0,
        comments: [],
        type: "story",
        url: URL(string: "https://any-url.com")!
    )
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
