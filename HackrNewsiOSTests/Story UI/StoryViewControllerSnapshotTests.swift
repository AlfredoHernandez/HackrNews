//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsiOS
import XCTest

final class StoryViewControllerSnapshotTests: XCTestCase {
    func test_emptyStories() {
        let fixedDate = Date(timeIntervalSince1970: 754790400)
        let story = StoryDetail(
            title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
            author: "a_username",
            score: 10,
            createdAt: fixedDate,
            totalComments: 0,
            comments: [],
            url: anyURL()
        )
        let cell = StoryCellController(model: story)
        let sut = StoryViewController(storyCellController: cell)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "story_details_dark")
    }
}
