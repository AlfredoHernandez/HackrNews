//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import HackrNewsiOS
import XCTest

final class LiveHackrNewsUIIntegrationTests: XCTestCase {
    func test_controllerTopStories_hasTitle() {
        let (sut, _) = makeSUT(contentType: .topStories)

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, topStoriesTitle)
        XCTAssertEqual(sut.tabBarItem.image, Icons.top.image(state: .normal))
        XCTAssertEqual(sut.tabBarItem.selectedImage, Icons.top.image(state: .selected))
    }

    func test_controllerNewStories_hasTitle() {
        let (sut, _) = makeSUT(contentType: .newStories)

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, newStoriesTitle)
        XCTAssertEqual(sut.tabBarItem.image, Icons.new.image(state: .normal))
        XCTAssertEqual(sut.tabBarItem.selectedImage, Icons.new.image(state: .selected))
    }

    func test_controllerBestStories_isConfigured() {
        let (sut, _) = makeSUT(contentType: .bestStories)

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, bestStoriesTitle)
        XCTAssertEqual(sut.tabBarItem.image, Icons.best.image(state: .normal))
        XCTAssertEqual(sut.tabBarItem.selectedImage, Icons.best.image(state: .selected))
    }

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
        let new1 = makeLiveHackrNew(id: 1)
        let new2 = makeLiveHackrNew(id: 2)

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [new1, new2], at: 0)

        XCTAssertEqual(loader.storiesRequestsCallCount, 0, "Expected no story URL requests until views become visible")

        sut.simulateStoryViewVisible(at: 0)
        XCTAssertEqual(loader.storiesRequestsCallCount, 1, "Expected first story URL request once first view becomes visible")

        sut.simulateStoryViewVisible(at: 1)
        XCTAssertEqual(
            loader.storiesRequestsCallCount, 2,
            "Expected second story URL request once second view also becomes visible"
        )
    }

    func test_liveHackrNewView_cancelsStoryLoadingWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let new1 = makeLiveHackrNew(id: 1)
        let new2 = makeLiveHackrNew(id: 2)

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [new1, new2], at: 0)

        XCTAssertEqual(loader.cancelledStoryUrls, 0, "Expected no cancelled story URL requests until views become visible")

        sut.simulateStoryViewNotVisible(at: 0)
        XCTAssertEqual(
            loader.cancelledStoryUrls,
            1,
            "Expected first story URL request cancelled once first view becomes not visible"
        )

        sut.simulateStoryViewNotVisible(at: 1)
        XCTAssertEqual(
            loader.cancelledStoryUrls,
            2,
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
        let locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar(identifier: .gregorian)
        let (sut, loader) = makeSUT(locale: locale, calendar: calendar)
        let (story0, story0VM) = makeStory(
            title: "a title",
            author: "an author",
            score: (2, "2 points"),
            createdAt: (Date(timeIntervalSince1970: 1175714200), "Apr 04, 2007")
        )
        let (story1, story1VM) = makeStory(
            title: "another title",
            author: "another author",
            score: (1, "1 points"),
            createdAt: (Date(timeIntervalSince1970: 1175714200), "Apr 04, 2007")
        )

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [makeLiveHackrNew(), makeLiveHackrNew()], at: 0)

        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)

        loader.completeStoryLoading(with: story0, at: 0)
        XCTAssertEqual(view0?.titleText, story0VM.title)
        XCTAssertEqual(view0?.urlText, story0VM.displayURL)
        XCTAssertEqual(view0?.authorText, story0VM.author)
        XCTAssertEqual(view0?.scoreText, story0VM.score)
        XCTAssertEqual(view0?.commentsText, story0VM.comments)
        XCTAssertEqual(view0?.createdAtText, story0VM.date)

        loader.completeStoryLoading(with: story1, at: 1)
        XCTAssertEqual(view1?.titleText, story1VM.title)
        XCTAssertEqual(view1?.urlText, story1VM.displayURL)
        XCTAssertEqual(view1?.authorText, story1VM.author)
        XCTAssertEqual(view1?.scoreText, story1VM.score)
        XCTAssertEqual(view1?.commentsText, story1VM.comments)
        XCTAssertEqual(view0?.createdAtText, story1VM.date)
    }

    func test_storyCell_hasSkeletonableViews() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [makeLiveHackrNew()])
        let view = sut.simulateStoryViewVisible(at: 0)

        XCTAssertEqual(view?.containerView?.isSkeletonable, true, "Expected containerView to be skeletonable")
        XCTAssertEqual(view?.leftContainerView?.isSkeletonable, true, "Expected leftContainerView to be skeletonable")
        XCTAssertEqual(view?.middleContainerView?.isSkeletonable, true, "Expected middleContainerView to be skeletonable")
        XCTAssertEqual(view?.storyUserInfoView?.isSkeletonable, true, "Expected storyUserInfoView to be skeletonable")
        XCTAssertEqual(view?.titleView?.isSkeletonable, true, "Expected titleView to be skeletonable")
        XCTAssertEqual(view?.authorView?.isSkeletonable, true, "Expected authorView to be skeletonable")
        XCTAssertEqual(view?.scoreView?.isSkeletonable, true, "Expected scoreView to be skeletonable")
        XCTAssertEqual(view?.createdAtView?.isSkeletonable, true, "Expected createdAtView to be skeletonable")
        XCTAssertEqual(view?.commentsView?.isSkeletonable, true, "Expected commentsView to be skeletonable")
    }

    func test_storyViewRetryButton_isVisibleOnStoryLoadedWithErrorAndHidesContainer() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [makeLiveHackrNew(), makeLiveHackrNew()], at: 0)

        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)

        loader.completeStoryLoading(at: 0)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view0?.isShowingStoryContainer, true)
        XCTAssertEqual(view1?.isShowingRetryAction, false)
        XCTAssertEqual(view1?.isShowingStoryContainer, true)

        loader.completeStoryLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingRetryAction, false)
        XCTAssertEqual(view0?.isShowingStoryContainer, true)
        XCTAssertEqual(view1?.isShowingRetryAction, true)
        XCTAssertEqual(view1?.isShowingStoryContainer, false)
    }

    func test_storyRetryAction_retriesStoryLoad() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeLiveHackrNew(id: 0)
        let lhn1 = makeLiveHackrNew(id: 1)
        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [lhn0, lhn1], at: 0)

        let view0 = sut.simulateStoryViewVisible(at: 0)
        let view1 = sut.simulateStoryViewVisible(at: 1)
        XCTAssertEqual(loader.storiesRequestsCallCount, 2, "Expected to load both urls")

        loader.completeStoryLoadingWithError(at: 0)
        loader.completeStoryLoadingWithError(at: 1)
        XCTAssertEqual(loader.storiesRequestsCallCount, 2, "Expected no more loadings when completes with error")

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.storiesRequestsCallCount, 3, "Expected one more url after first tap retry action")

        view1?.simulateRetryAction()
        XCTAssertEqual(loader.storiesRequestsCallCount, 4, "Expected another url after second tap retry action")
    }

    func test_storyView_preloadsStoryWhenIsNearVisible() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeLiveHackrNew(id: 0)
        let lhn1 = makeLiveHackrNew(id: 1)

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [lhn0, lhn1], at: 0)
        XCTAssertEqual(loader.storiesRequestsCallCount, 0, "Expected no stories urls before views are near to be visible")

        sut.simulateStoryNearViewVisible(at: 0)
        XCTAssertEqual(loader.storiesRequestsCallCount, 1, "Expected first url after first view is near to be visible")

        sut.simulateStoryNearViewVisible(at: 1)
        XCTAssertEqual(loader.storiesRequestsCallCount, 2, "Expected first and second urls after second view is near to be visible")
    }

    func test_storyView_cancelsStoryPreloadingWhenNotNearVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeLiveHackrNew(id: 0)
        let lhn1 = makeLiveHackrNew(id: 1)

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [lhn0, lhn1], at: 0)
        XCTAssertEqual(loader.cancelledStoryUrls, 0, "Expected no stories urls before views are near to be visible")

        sut.simulateStoryNotNearViewVisible(at: 0)
        XCTAssertEqual(loader.cancelledStoryUrls, 1, "Expected first canceld url after first view is near to be visible")

        sut.simulateStoryNotNearViewVisible(at: 1)
        XCTAssertEqual(
            loader.cancelledStoryUrls,
            2,
            "Expected first and second urls canceled after second view is near to be visible"
        )
    }

    func test_storyView_doesNotRenderStoryContentWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeLiveHackrNew(id: 0)
        let story0 = makeStory()

        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [lhn0], at: 0)
        let view = sut.simulateStoryViewNotVisible(at: 0)

        loader.completeStoryLoading(with: story0.model, at: 0)

        XCTAssertNotEqual(
            view?.titleText,
            story0.viewModel.title,
            "Expected default `loading item..` text, but got \(String(describing: view?.titleText))"
        )
        XCTAssertNotEqual(
            view?.authorText,
            story0.viewModel.author,
            "Expected default `loading item..` text, but got \(String(describing: view?.authorText))"
        )
        XCTAssertNotEqual(
            view?.scoreText,
            story0.viewModel.score,
            "Expected default `loading item..` text, but got \(String(describing: view?.scoreText))"
        )
        XCTAssertNotEqual(
            view?.createdAtText,
            story0.viewModel.date,
            "Expected default `loading item..` text, but got \(String(describing: view?.createdAtText))"
        )
        XCTAssertNotEqual(
            view?.commentsText,
            story0.viewModel.comments,
            "Expected default `loading item..` text, but got \(String(describing: view?.commentsText))"
        )
    }

    // MARK: - Selection handler tests

    func test_didSelectStory_triggersHandlerWithUrl() {
        var handledURLs = [URL]()
        let (sut, loader) = makeSUT(selection: { handledURLs.append($0) })
        let url1 = URL(string: "https://any-url.com/first")!
        let (lhn1, story1) = makeLiveHackrNewAndStory(id: 1, url: url1)
        let url2 = URL(string: "https://any-url.com/second")!
        let (lhn2, story2) = makeLiveHackrNewAndStory(id: 2, url: url2)
        sut.loadViewIfNeeded()
        loader.completeLiveHackrNewsLoading(with: [lhn1, lhn2], at: 0)

        sut.simulateStoryViewVisible(at: 0)
        sut.simulateTapOnStory(at: 0)
        XCTAssertTrue(handledURLs.isEmpty, "Expected to not trigger selection action with URL \(url1) when is loading")

        loader.completeStoryLoading(with: story1, at: 0)
        sut.simulateTapOnStory(at: 0)
        XCTAssertEqual(handledURLs, [url1], "Expected to trigger selection action with URL \(url1), but got \(handledURLs)")

        sut.simulateStoryViewVisible(at: 1)
        sut.simulateTapOnStory(at: 1)
        XCTAssertEqual(handledURLs, [url1], "Expected to not trigger second selection action with URL \(url2) when is loading")

        loader.completeStoryLoading(with: story2, at: 1)
        sut.simulateTapOnStory(at: 1)
        XCTAssertEqual(
            handledURLs,
            [url1, url2],
            "Expected to trigger selection action with URL \(url1) and \(url2), but got \(handledURLs)"
        )
    }

    // MARK: - Dispatching to main thread tests

    func test_loadLiveHackrNewsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for loader completion")
        DispatchQueue.global().async {
            loader.completeLiveHackrNewsLoading()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadLiveHackrNewsCompletion_dispatchesStoryLoaderFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeLiveHackrNew(id: 0)
        let story0 = makeStory().model
        sut.loadViewIfNeeded()

        loader.completeLiveHackrNewsLoading(with: [lhn0], at: 0)
        sut.simulateStoryViewVisible(at: 0)

        let exp = expectation(description: "Wait for loader completion")
        DispatchQueue.global().async {
            loader.completeStoryLoading(with: story0, at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(
        selection: @escaping (URL) -> Void = { _ in },
        contentType: ContentType = .newStories,
        locale: Locale = .current,
        calendar: Calendar = Calendar(identifier: .gregorian),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (HackrNewsFeedViewController, LiveHackerNewLoaderSpy) {
        let loader = LiveHackerNewLoaderSpy()
        let sut = HackrNewsFeedUIComposer.composeWith(
            contentType: contentType,
            hackrNewsFeedloader: loader,
            hackrStoryLoader: { _ in loader },
            didSelectStory: selection,
            locale: locale,
            calendar: calendar
        )
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private func makeLiveHackrNew(id: Int = Int.random(in: 0 ... 100)) -> HackrNew {
        HackrNew(id: id)
    }

    private func makeLiveHackrNewAndStory(id: Int = 1, url: URL) -> (new: HackrNew, story: Story) {
        let lhn = HackrNew(id: id)
        let story = makeStory(id: id, url: url).model
        return (lhn, story)
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
    ) -> (model: Story, viewModel: StoryViewModel) {
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
            comments: "\(totalComments) comments",
            score: score.representation,
            date: createdAt.representation,
            url: url,
            displayURL: url.host
        )
        return (model, viewModel)
    }

    private var topStoriesTitle: String {
        LiveHackrNewsPresenter.topStoriesTitle
    }

    private var newStoriesTitle: String {
        LiveHackrNewsPresenter.newStoriesTitle
    }

    private var bestStoriesTitle: String {
        LiveHackrNewsPresenter.bestStoriesTitle
    }
}
