//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
@testable import HackrNewsiOS
import SafariServices
import XCTest

final class HackrNewsAppAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let stories = launch(httpClient: .online(response))

        XCTAssertEqual(stories.numberOfRenderedHackrNewsFeedViews(), 5)

        let view0 = stories.simulateStoryViewVisible(at: 0)
        let view1 = stories.simulateStoryViewVisible(at: 1)

        XCTAssertNotNil(view0, "Expected view0 to be not nil")
        XCTAssertNotNil(view1, "Expected view1 to be not nil")

        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected to not display retry indicator in view0")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected to not display retry indicator in view1")
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateStoryViewVisible(at: 0)

        let cachedFeed = launch(httpClient: .online(cachedStoriesResponse), store: sharedStore)
        let view0 = cachedFeed.simulateStoryViewVisible(at: 0)

        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected to not display retry indicator in view0")
    }

    func test_refreshFeed_deletesExpiredCachedStories() {
        let store = InMemoryFeedStore.withExpiredCache

        let onlineFeed = launch(httpClient: .online(cachedStoriesResponse), store: store)
        onlineFeed.simulateUserInitiatedHackrNewsFeedReload()

        XCTAssertEqual(store.stories.count, 0, "Expected to delete expired stories")
    }

    func test_refreshFeed_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredCache

        let onlineFeed = launch(httpClient: .online(cachedStoriesResponse), store: store)
        onlineFeed.simulateUserInitiatedHackrNewsFeedReload()

        XCTAssertEqual(store.stories.count, 2, "Expected to not delete expired stories")
    }

    func test_onLaunch_doesNotDisplayRemoteStoriesWhenCustomerHasNotConnectivity() {
        let stories = launch(httpClient: .offline)

        XCTAssertEqual(stories.numberOfRenderedHackrNewsFeedViews(), 0)
    }

    func test_onSelectStory_displaysStoryDetails() {
        let storyDetails = showStoryDetailsForFirstStory()
        let view = storyDetails?.simulateStoryDetailViewVisible()

        XCTAssertEqual(view?.titleLabel.text, "Welcome to HackrNewsApp")
        XCTAssertEqual(view?.authorLabel.text, "AlfredoHernandez")
    }

    func test_onSelectStory_displaysStoryComments() {
        let storyDetails = showStoryDetailsForFirstStory()

        XCTAssertEqual(storyDetails?.numberOfRenderedComments(), 5)
    }

    func test_onSelectStoryDetails_opensSafariWithURL() {
        let storyDetails = showStoryDetailsForFirstStory()
        storyDetails?.simulateStoryDetailViewVisible()

        storyDetails?.simulateTapOnStoryDetailsView()

        XCTAssertNotNil(storyDetails?.presentedViewController as? SFSafariViewController)
    }

    func test_onLaunchandTapNewStories_displaysRemoteStoriesWhenCustomesHasConnectivity() {
        let app = launch(httpClient: .online(response))

        let topStories = app.simulateTapOnTopStories()
        XCTAssertNotNil(topStories, "Expected a `\(HackrNewsFeedViewController.self)` to display new stories")
        XCTAssertEqual(topStories.title, HackrNewsFeedPresenter.topStoriesTitle)

        let newStories = app.simulateTapOnNewStories()
        XCTAssertNotNil(newStories, "Expected a `\(HackrNewsFeedViewController.self)` to display new stories")
        XCTAssertEqual(newStories.title, HackrNewsFeedPresenter.newStoriesTitle)

        let bestStories = app.simulateTapOnBestStories()
        XCTAssertNotNil(bestStories, "Expected a `\(HackrNewsFeedViewController.self)` to display new stories")
        XCTAssertEqual(bestStories.title, HackrNewsFeedPresenter.bestStoriesTitle)
    }

    func test_onTabBarTapSelection_triggersTabActionOnSameControllerSelection() {
        var actionSelectionCallCount = 0
        let app = launch(httpClient: .online(response), tabBarAction: { _ in
            actionSelectionCallCount += 1
        })

        app.simulateTapOnTabItem()
        XCTAssertEqual(actionSelectionCallCount, 0, "Expected to no trigger tab action on non same controller selection")

        app.simulateTapOnTabItem()
        XCTAssertEqual(actionSelectionCallCount, 1, "Expected to trigger tab action on same controller selection")
    }

    // MARK: - Helpers

    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: HackrNewsStoryStore = InMemoryFeedStore.empty,
        tabBarAction: ((UIViewController) -> Void)? = nil
    ) -> HackrNewsFeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.tabBarAction = tabBarAction
        sut.window = UIWindow()

        sut.configureWindow()

        let tabBarController = sut.window?.rootViewController as! UITabBarController
        return tabBarController.firstViewController
    }

    private func showStoryDetailsForFirstStory(file: StaticString = #filePath, line: UInt = #line) -> StoryDetailsViewController? {
        let stories = launch(httpClient: .online(response), store: InMemoryFeedStore.empty)
        stories.simulateStoryViewVisible(at: 0)

        stories.simulateTapOnStory(at: 0)
        RunLoop.current.run(until: Date())

        let controller = stories.navigationController?.topViewController
        let storyDetails = controller as? StoryDetailsViewController
        XCTAssertNotNil(
            storyDetails,
            "Expected a \(String(describing: StoryDetailsViewController.self)) controller, got \(String(describing: storyDetails))",
            file: file,
            line: line
        )
        return storyDetails
    }
}
