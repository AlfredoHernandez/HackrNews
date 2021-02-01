//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsiOS
import XCTest

final class StoryDetailsViewControllerIntegrationTests: XCTestCase {
    func test_controllerTopStories_hasTitle() {
        let sut = makeSUT(story: anyStoryDetail())

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, StoryDetailsPresenter.title)
    }

    func test_commentsSection_hasTitle() {
        let sut = makeSUT(story: anyStoryDetail())

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.commentsTitle, StoryDetailsPresenter.title)
    }

    func test_viewDidLoad_displaysStory() {
        let fixedDate = Date().adding(days: -1)
        let story = StoryDetail(
            title: "a title",
            text: "a text",
            author: "an author",
            score: 10,
            createdAt: fixedDate,
            totalComments: 0,
            comments: [],
            url: anyURL()
        )
        let sut = makeSUT(story: story)

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.titleText, story.title)
        XCTAssertEqual(sut.authorText, story.author)
        XCTAssertEqual(sut.bodyText, story.text)
        XCTAssertEqual(sut.scoreText, "10 points")
        XCTAssertEqual(sut.commentsText, "0 comments")
        XCTAssertEqual(sut.createdAtText, "1 day ago")
        XCTAssertEqual(sut.urlText, "any-url.com")
    }

    func test_viewDidLoad_displaysStoryWithoutBodyContent() {
        let sut = makeSUT(story: anyStoryDetail(withBody: false))

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.bodyText, nil)
    }

    func test_detailCell_isReusableWhenNotVisibleAnymore() {
        let sut = makeSUT(story: anyStoryDetail())
        sut.loadViewIfNeeded()

        sut.simulateStoryDetailViewVisible()
        XCTAssertFalse(sut.detailViewIsReusable)

        sut.simulateStoryDetailViewNotVisible()
        XCTAssertTrue(sut.detailViewIsReusable, "Expected release cell when view is not visible")
    }

    // MARK: - Helpers

    private func makeSUT(story: StoryDetail) -> StoryDetailsViewController {
        let sut = StoryDetailsUIComposer.composeWith(model: story)
        return sut
    }

    private func anyStoryDetail(withBody: Bool = true) -> StoryDetail {
        StoryDetail(
            title: "any title",
            text: withBody ? "any text" : nil,
            author: "any author",
            score: 0,
            createdAt: Date(),
            totalComments: 0,
            comments: [],
            url: anyURL()
        )
    }
}
