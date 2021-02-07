//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
@testable import HackrNewsiOS
import SafariServices
import XCTest

final class HackrNewsAppAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteStoriesWhenCustomerHasConnectivity() {
        let stories = launch(httpClient: .online(response))

        XCTAssertEqual(stories.numberOfRenderedHackrNewsFeedViews(), 5)

        let view0 = stories.simulateStoryViewVisible(at: 0)
        let view1 = stories.simulateStoryViewVisible(at: 1)

        XCTAssertNotNil(view0, "Expected view0 to be not nil")
        XCTAssertNotNil(view1, "Expected view1 to be not nil")

        XCTAssertEqual(view0?.isShowingRetryAction, false, "Expected to not display retry indicator in view0")
        XCTAssertEqual(view1?.isShowingRetryAction, false, "Expected to not display retry indicator in view1")
    }

    func test_onLaunch_doesNotDisplayRemoteStoriesWhenCustomerHasNotConnectivity() {
        let stories = launch(httpClient: .offline)

        XCTAssertEqual(stories.numberOfRenderedHackrNewsFeedViews(), 0)
    }

    func test_onSelectStory_displaysStoryDetails() {
        let storyDetails = showStoryDetailsForFirstStory()
        let view = storyDetails?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? StoryDetailCell

        XCTAssertEqual(view?.titleLabel.text, "Welcome to HackrNewsApp")
        XCTAssertEqual(view?.authorLabel.text, "AlfredoHernandez")
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

    // MARK: - Helpers

    private func launch(httpClient: HTTPClientStub = .offline) -> HackrNewsFeedViewController {
        let sut = SceneDelegate(httpClient: httpClient)
        sut.window = UIWindow()

        sut.configureWindow()

        let tabBarController = sut.window?.rootViewController as! UITabBarController
        return tabBarController.firstViewController
    }

    private func showStoryDetailsForFirstStory(file: StaticString = #filePath, line: UInt = #line) -> StoryDetailsViewController? {
        let stories = launch(httpClient: .online(response))
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
