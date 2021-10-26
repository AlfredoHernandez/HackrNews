//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import HackrNews
import HackrNewsApp
import HackrNewsiOS
import XCTest

final class HackrNewsFeedSwiftUIIntegrationTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    func test_view_hasTitle() {
        let (sutA, _) = makeSUT(contentType: .topStories)
        XCTAssertEqual(sutA.title, HackrNewsFeedPresenter.topStoriesTitle)

        let (sutB, _) = makeSUT(contentType: .bestStories)
        XCTAssertEqual(sutB.title, HackrNewsFeedPresenter.bestStoriesTitle)

        let (sutC, _) = makeSUT(contentType: .newStories)
        XCTAssertEqual(sutC.title, HackrNewsFeedPresenter.newStoriesTitle)
    }

    func test_loadHackrNewsFeedActions_requestHackrNewsFeedLoader() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)

        sut.load()
        XCTAssertEqual(loader.loadCallCount, 1)

        loader.completeHackrNewsFeedLoading(at: 0)
        sut.simulateUserInitiatedHackrNewsFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        loader.completeHackrNewsFeedLoading(at: 1)
        sut.simulateUserInitiatedHackrNewsFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    func test_loadHackrNewsFeed_doesNotLoadFeedUntilPreviousRequestCompletes() {
        let (sut, loader) = makeSUT()

        sut.load()
        XCTAssertEqual(loader.loadCallCount, 1)

        sut.simulateUserInitiatedHackrNewsFeedReload()
        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_loadHackrNewsFeedCompletion_rendersSuccessfullyLoadedHackrNewsFeed() {
        let (sut, loader) = makeSUT()
        let new1 = HackrNew.fixture(id: 1)
        let new2 = HackrNew.fixture(id: 2)
        let new3 = HackrNew.fixture(id: 3)
        let new4 = HackrNew.fixture(id: 4)

        sut.load()
        assertThat(sut, isRendering: [])

        loader.completeHackrNewsFeedLoading(with: [new1], at: 0)
        assertThat(sut, isRendering: [new1])

        sut.simulateUserInitiatedHackrNewsFeedReload()
        loader.completeHackrNewsFeedLoading(with: [new1, new2, new3, new4], at: 1)
        assertThat(sut, isRendering: [new1, new2, new3, new4])
    }

    func test_loadHackrNewsFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (sut, loader) = makeSUT()
        let new1 = HackrNew.fixture(id: 1)

        sut.load()
        loader.completeHackrNewsFeedLoading(with: [new1], at: 0)
        assertThat(sut, isRendering: [new1])

        sut.simulateUserInitiatedHackrNewsFeedReload()
        loader.completeHackrNewsFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [new1])
    }

    func test_load_isCalledOnceWhenViewAppear() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)

        sut.load()
        loader.completeHackrNewsFeedLoading()
        XCTAssertEqual(loader.loadCallCount, 1)

        sut.load()
        XCTAssertEqual(loader.loadCallCount, 1)
    }

    func test_news_notifiesToView() {
        let (sut, loader) = makeSUT()
        let expectation = XCTestExpectation(description: "Wait for loader")

        sut.load()
        XCTAssertEqual(sut.news.count, 0, "Expected no items")

        sut.$news.dropFirst().sink(receiveValue: { receivedItems in
            XCTAssertEqual(receivedItems.count, 3, "Expected 3 items")
            expectation.fulfill()
        }).store(in: &cancellables)

        loader.completeHackrNewsFeedLoading(with: [.fixture(), .fixture(), .fixture()], at: 0)
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(
        contentType: ContentType = .topStories,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (NewsFeedViewModel, HackrNewsFeedLoaderSpy) {
        let loader = HackrNewsFeedLoaderSpy()
        let sut = NewsFeedViewModel(contentType: contentType, hackrNewsFeedloader: {
            loader.publisher()
        })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    func assertThat(
        _ sut: NewsFeedViewModel,
        isRendering feed: [HackrNew],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedHackrNewsFeedViews() == feed.count else {
            return XCTFail(
                "Expected \(feed.count) news, got \(sut.numberOfRenderedHackrNewsFeedViews()) instead.",
                file: file,
                line: line
            )
        }
    }
}

extension NewsFeedViewModel {
    func simulateUserInitiatedHackrNewsFeedReload() {
        refresh()
    }

    func numberOfRenderedHackrNewsFeedViews() -> Int {
        news.count
    }
}