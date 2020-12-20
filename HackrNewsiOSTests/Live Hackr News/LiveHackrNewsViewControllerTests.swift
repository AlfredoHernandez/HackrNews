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

    func test_storyView_displaysStoryInfo() {
        let (sut, loader) = makeSUT()
        let (story0, story0VM) = makeStory(
            title: "a title",
            author: "an author",
            score: (2, "2 points"),
            createdAt: (Date(timeIntervalSince1970: 1607645758000), "Dec 11, 2020")
        )
        let (story1, story1VM) = makeStory(
            title: "another title",
            author: "another author",
            score: (1, "1 points"),
            createdAt: (Date(timeIntervalSince1970: 1606940829000), "Dec 11, 2020")
        )

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [makeLiveHackrNew(), makeLiveHackrNew()], at: 0)

        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)

        loader.completeStoryLoading(with: story0, at: 0)
        XCTAssertEqual(view0?.titleText, story0VM.title)
        XCTAssertEqual(view0?.authorText, story0VM.author)
        XCTAssertEqual(view0?.scoreText, story0VM.score)
        XCTAssertEqual(view0?.commentsText, story0VM.comments)

        loader.completeStoryLoading(with: story1, at: 1)
        XCTAssertEqual(view1?.titleText, story1VM.title)
        XCTAssertEqual(view1?.authorText, story1VM.author)
        XCTAssertEqual(view1?.scoreText, story1VM.score)
        XCTAssertEqual(view1?.commentsText, story1VM.comments)
    }

    func test_storyViewRetryButton_isVisibleOnStoryLoadedWithError() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [makeLiveHackrNew(), makeLiveHackrNew()], at: 0)

        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)

        loader.completeStoryLoading(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, false)

        loader.completeStoryLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingRetryAction, true)
    }

    func test_storyRetryAction_retriesStoryLoad() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeLiveHackrNew(id: 0, url: URL(string: "http://any-url.com/0.json")!)
        let lhn1 = makeLiveHackrNew(id: 1, url: URL(string: "http://any-url.com/1.json")!)
        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [lhn0, lhn1], at: 0)

        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)
        XCTAssertEqual(loader.loadedStoryUrls, [lhn0.url, lhn1.url], "Expected to load both urls")

        loader.completeStoryLoadingWithError(at: 0)
        loader.completeStoryLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedStoryUrls, [lhn0.url, lhn1.url], "Expected no more loadings when completes with error")

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedStoryUrls, [lhn0.url, lhn1.url, lhn0.url], "Expected one more url after first tap retry action")

        view1?.simulateRetryAction()
        XCTAssertEqual(
            loader.loadedStoryUrls,
            [lhn0.url, lhn1.url, lhn0.url, lhn1.url],
            "Expected another url after second tap retry action"
        )
    }

    func test_storyView_preloadsStoryWhenIsNearVisible() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeLiveHackrNew(id: 0, url: URL(string: "http://any-url.com/0.json")!)
        let lhn1 = makeLiveHackrNew(id: 1, url: URL(string: "http://any-url.com/1.json")!)

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [lhn0, lhn1], at: 0)
        XCTAssertEqual(loader.loadedStoryUrls, [], "Expected no stories urls before views are near to be visible")

        sut.simulateStoryNearViewVisible(at: 0)
        XCTAssertEqual(loader.loadedStoryUrls, [lhn0.url], "Expected first url after first view is near to be visible")

        sut.simulateStoryNearViewVisible(at: 1)
        XCTAssertEqual(
            loader.loadedStoryUrls,
            [lhn0.url, lhn1.url],
            "Expected first and second urls after second view is near to be visible"
        )
    }

    func test_storyView_cancelsStoryPreloadingWhenNotNearVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeLiveHackrNew(id: 0, url: URL(string: "http://any-url.com/0.json")!)
        let lhn1 = makeLiveHackrNew(id: 1, url: URL(string: "http://any-url.com/1.json")!)

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [lhn0, lhn1], at: 0)
        XCTAssertEqual(loader.cancelledStoryUrls, [], "Expected no stories urls before views are near to be visible")

        sut.simulateStoryNotNearViewVisible(at: 0)
        XCTAssertEqual(loader.cancelledStoryUrls, [lhn0.url], "Expected first canceld url after first view is near to be visible")

        sut.simulateStoryNotNearViewVisible(at: 1)
        XCTAssertEqual(
            loader.cancelledStoryUrls,
            [lhn0.url, lhn1.url],
            "Expected first and second urls canceled after second view is near to be visible"
        )
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LiveHackrNewsViewController, LiveHackerNewLoaderSpy) {
        let loader = LiveHackerNewLoaderSpy()
        let sut = LiveHackrNewsUIComposer.composeWith(liveHackrNewsloader: loader, hackrStoryLoader: loader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private func makeLiveHackrNew(id: Int = Int.random(in: 0 ... 100), url: URL = URL(string: "https://any-url.com")!) -> LiveHackrNew {
        LiveHackrNew(id: id, url: url)
    }

    private func makeStory(
        id: Int = 0,
        title: String = "",
        author: String = "",
        score: (number: Int, representation: String) = (0, "0 points"),
        createdAt: (date: Date, representation: String) = (Date(), ""),
        totalComments: Int = 0,
        comments: [Int] = [],
        type: String = "",
        url: URL = URL(string: "https://any-url.com")!
    ) -> (Story, StoryViewModel) {
        let model = Story(
            id: id,
            title: title,
            author: author,
            score: score.number,
            createdAt: createdAt.date,
            totalComments: totalComments,
            comments: comments,
            type: type,
            url: url
        )
        let viewModel = StoryViewModel(
            newId: id,
            title: title,
            author: author,
            comments: "\(comments.count)",
            score: score.representation,
            date: createdAt.representation
        )
        return (model, viewModel)
    }
}
