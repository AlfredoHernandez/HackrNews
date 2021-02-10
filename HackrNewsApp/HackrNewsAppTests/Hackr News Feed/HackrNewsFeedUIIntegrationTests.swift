//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import HackrNewsiOS
import XCTest

final class HackrNewsFeedUIIntegrationTests: XCTestCase {
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

    func test_loadHackrNewsFeedActions_requestHackrNewsFeedLoader() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)

        sut.simulateUserInitiatedHackrNewsFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulateUserInitiatedHackrNewsFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    func test_loadingHackrNewsFeedIndicator_isVisibleWhileLoadingHackrNewsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected show loading indicator once view is loaded")

        loader.completeHackrNewsFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes successfully")

        sut.simulateUserInitiatedHackrNewsFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected show loading indicator once user initiated loading")

        loader.completeHackrNewsFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }

    func test_loadHackrNewsFeedCompletion_rendersSuccessfullyLoadedHackrNewsFeed() {
        let (sut, loader) = makeSUT()
        let new1 = makeHackrNew(id: 1)
        let new2 = makeHackrNew(id: 2)
        let new3 = makeHackrNew(id: 3)
        let new4 = makeHackrNew(id: 4)

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeHackrNewsFeedLoading(with: [new1], at: 0)
        assertThat(sut, isRendering: [new1])

        sut.simulateUserInitiatedHackrNewsFeedReload()
        loader.completeHackrNewsFeedLoading(with: [new1, new2, new3, new4], at: 1)
        assertThat(sut, isRendering: [new1, new2, new3, new4])
    }

    func test_loadHackrNewsFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let (sut, loader) = makeSUT()
        let new1 = makeHackrNew(id: 1)

        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [new1], at: 0)
        assertThat(sut, isRendering: [new1])

        sut.simulateUserInitiatedHackrNewsFeedReload()
        loader.completeHackrNewsFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [new1])
    }

    func test_storyView_loadsStoryURLWhenVisible() {
        let (sut, loader) = makeSUT()
        let new1 = makeHackrNew(id: 1)
        let new2 = makeHackrNew(id: 2)

        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [new1, new2], at: 0)

        XCTAssertEqual(loader.storiesRequestsCallCount, 0, "Expected no story URL requests until views become visible")

        sut.simulateStoryViewVisible(at: 0)
        XCTAssertEqual(loader.storiesRequestsCallCount, 1, "Expected first story URL request once first view becomes visible")

        sut.simulateStoryViewVisible(at: 1)
        XCTAssertEqual(
            loader.storiesRequestsCallCount, 2,
            "Expected second story URL request once second view also becomes visible"
        )
    }

    func test_hackrNewFeedView_cancelsStoryLoadingWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let new1 = makeHackrNew(id: 1)
        let new2 = makeHackrNew(id: 2)

        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [new1, new2], at: 0)

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

    func test_hackrNewFeedViewLoadingIndicator_isVisibleWhileLoading() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [makeHackrNew(), makeHackrNew()], at: 0)

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
        loader.completeHackrNewsFeedLoading(with: [makeHackrNew(), makeHackrNew()], at: 0)

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
        loader.completeHackrNewsFeedLoading(with: [makeHackrNew()])
        let view = sut.simulateStoryViewVisible(at: 0)

        XCTAssertEqual(view?.containerView?.isSkeletonable, true, "Expected containerView to be skeletonable")
        XCTAssertEqual(view?.leftContainerView?.isSkeletonable, true, "Expected leftContainerView to be skeletonable")
        XCTAssertEqual(view?.middleContainerView?.isSkeletonable, true, "Expected middleContainerView to be skeletonable")
        XCTAssertEqual(view?.storyUserInfoView?.isSkeletonable, true, "Expected storyUserInfoView to be skeletonable")
        XCTAssertEqual(view?.titleView?.isSkeletonable, true, "Expected titleView to be skeletonable")
        XCTAssertEqual(view?.authorView?.isSkeletonable, false, "Expected authorView to be skeletonable")
        XCTAssertEqual(view?.scoreView?.isSkeletonable, false, "Expected scoreView to be skeletonable")
        XCTAssertEqual(view?.createdAtView?.isSkeletonable, false, "Expected createdAtView to be skeletonable")
        XCTAssertEqual(view?.commentsView?.isSkeletonable, false, "Expected commentsView to be skeletonable")
    }

    func test_storyViewRetryButton_isVisibleOnStoryLoadedWithErrorAndHidesContainer() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [makeHackrNew(), makeHackrNew()], at: 0)

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
        let lhn0 = makeHackrNew(id: 0)
        let lhn1 = makeHackrNew(id: 1)
        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [lhn0, lhn1], at: 0)

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
        let lhn0 = makeHackrNew(id: 0)
        let lhn1 = makeHackrNew(id: 1)

        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [lhn0, lhn1], at: 0)
        XCTAssertEqual(loader.storiesRequestsCallCount, 0, "Expected no stories urls before views are near to be visible")

        sut.simulateStoryNearViewVisible(at: 0)
        XCTAssertEqual(loader.storiesRequestsCallCount, 1, "Expected first url after first view is near to be visible")

        sut.simulateStoryNearViewVisible(at: 1)
        XCTAssertEqual(loader.storiesRequestsCallCount, 2, "Expected first and second urls after second view is near to be visible")
    }

    func test_storyView_cancelsStoryPreloadingWhenNotNearVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeHackrNew(id: 0)
        let lhn1 = makeHackrNew(id: 1)

        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [lhn0, lhn1], at: 0)
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
        let lhn0 = makeHackrNew(id: 0)
        let story0 = makeStory()

        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [lhn0], at: 0)
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
        var stories = [Story]()
        let (sut, loader) = makeSUT(selection: { stories.append($0) })
        let url1 = URL(string: "https://any-url.com/first")!
        let (lhn1, story1) = makeHackrNewAndStory(id: 1, url: url1)
        let url2 = URL(string: "https://any-url.com/second")!
        let (lhn2, story2) = makeHackrNewAndStory(id: 2, url: url2)
        sut.loadViewIfNeeded()
        loader.completeHackrNewsFeedLoading(with: [lhn1, lhn2], at: 0)

        sut.simulateStoryViewVisible(at: 0)
        sut.simulateTapOnStory(at: 0)
        XCTAssertTrue(stories.isEmpty, "Expected to not trigger selection action with \(story1) when is loading")

        loader.completeStoryLoading(with: story1, at: 0)
        sut.simulateTapOnStory(at: 0)
        XCTAssertEqual(stories, [story1], "Expected to trigger selection action with \(story1), but got \(stories)")

        sut.simulateStoryViewVisible(at: 1)
        sut.simulateTapOnStory(at: 1)
        XCTAssertEqual(stories, [story1], "Expected to not trigger second selection action with \(story2) when is loading")

        loader.completeStoryLoading(with: story2, at: 1)
        sut.simulateTapOnStory(at: 1)
        XCTAssertEqual(
            stories,
            [story1, story2],
            "Expected to trigger selection action with \(story1) and \(story2), but got \(stories)"
        )
    }

    // MARK: - Dispatching to main thread tests

    func test_loadHackrNewsFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()

        let exp = expectation(description: "Wait for loader completion")
        DispatchQueue.global().async {
            loader.completeHackrNewsFeedLoading()
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    func test_loadStoryCompletion_dispatchesStoryLoaderFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        let lhn0 = makeHackrNew(id: 0)
        let story0 = makeStory().model
        sut.loadViewIfNeeded()

        loader.completeHackrNewsFeedLoading(with: [lhn0], at: 0)
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
        selection: @escaping (Story) -> Void = { _ in },
        contentType: ContentType = .newStories,
        locale: Locale = .current,
        calendar: Calendar = Calendar(identifier: .gregorian),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (HackrNewsFeedViewController, HackrNewsFeedLoaderSpy) {
        let loader = HackrNewsFeedLoaderSpy()
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

    private func makeHackrNew(id: Int = Int.random(in: 0 ... 100)) -> HackrNew {
        HackrNew(id: id)
    }

    private func makeHackrNewAndStory(id: Int = 1, url: URL) -> (new: HackrNew, story: Story) {
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
            text: nil,
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
        HackrNewsFeedPresenter.topStoriesTitle
    }

    private var newStoriesTitle: String {
        HackrNewsFeedPresenter.newStoriesTitle
    }

    private var bestStoriesTitle: String {
        HackrNewsFeedPresenter.bestStoriesTitle
    }
}
