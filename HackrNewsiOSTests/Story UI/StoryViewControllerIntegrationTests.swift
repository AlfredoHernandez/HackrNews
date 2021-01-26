//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import HackrNewsiOS
import XCTest

final class StoryViewControllerIntegrationTests: XCTestCase {
    func test_story_withDetails() {
        let fixedDate = Date().adding(days: -1)
        let story = StoryDetail(
            title: "a title",
            author: "an author",
            score: 10,
            createdAt: fixedDate,
            totalComments: 0,
            comments: [],
            url: anyURL()
        )
        let sut = StoryViewController(story: story)

        sut.loadViewIfNeeded()

        let view = sut.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? StoryDetailCell
        XCTAssertEqual(view?.titleLabel.text, story.title)
        XCTAssertEqual(view?.authorLabel.text, story.author)
        XCTAssertEqual(view?.scoreLabel.text, "10 points")
        XCTAssertEqual(view?.commentsLabel.text, "0 comments")
        XCTAssertEqual(view?.createdAtLabel.text, "1 day ago")
    }
}

extension Date {
    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .day, value: days, to: self)!
    }
}