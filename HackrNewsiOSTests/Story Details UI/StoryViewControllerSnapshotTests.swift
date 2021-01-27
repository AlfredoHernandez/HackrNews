//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsiOS
import XCTest

final class StoryViewControllerSnapshotTests: XCTestCase {
    func test_emptyStories() {
        let cell = StoryCellController(viewModel: StoryDetailViewModel(
            title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
            author: "a_username",
            score: "10 points",
            comments: "0 comments",
            createdAt: "27 years ago",
            displayURL: "any-url.com"
        ))
        let sut = StoryDetailsViewController(storyCellController: cell)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "story_details_dark")
    }
}
