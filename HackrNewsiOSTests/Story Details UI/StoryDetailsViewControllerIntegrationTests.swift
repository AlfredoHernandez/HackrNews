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

    func test_cell_dequeueCell() {
        let sut = makeSUT(story: anyStoryDetail())
        sut.loadViewIfNeeded()

        sut.simulateStoryDetailViewVisible()
        XCTAssertNotNil(sut.storyCellController?.cell)

        sut.simulateStoryDetailViewNotVisible()
        XCTAssertNil(sut.storyCellController?.cell, "Expected release cell when view is not visible")
    }

    // MARK: - Helpers

    private func makeSUT(story: StoryDetail) -> StoryDetailsViewController {
        let sut = StoryDetailsUIComposer.composeWith(model: story)
        return sut
    }

    private func anyStoryDetail() -> StoryDetail {
        StoryDetail(
            title: "any title",
            text: "any text",
            author: "any author",
            score: 0,
            createdAt: Date(),
            totalComments: 0,
            comments: [],
            url: anyURL()
        )
    }
}
