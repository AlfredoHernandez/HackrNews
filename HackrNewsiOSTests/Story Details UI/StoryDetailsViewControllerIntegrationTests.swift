//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsiOS
import XCTest

final class StoryDetailsViewControllerIntegrationTests: XCTestCase {
    func test_story_withDetails() {
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
        let sut = StoryDetailsUIComposer.composeWith(model: story)

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.titleText, story.title)
        XCTAssertEqual(sut.text, story.text)
        XCTAssertEqual(sut.authorText, story.author)
        XCTAssertEqual(sut.scoreText, "10 points")
        XCTAssertEqual(sut.commentsText, "0 comments")
        XCTAssertEqual(sut.createdAtText, "1 day ago")
        XCTAssertEqual(sut.urlText, "any-url.com")
    }
}
