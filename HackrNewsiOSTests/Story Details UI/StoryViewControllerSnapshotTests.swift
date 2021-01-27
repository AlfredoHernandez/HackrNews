//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsiOS
import XCTest

final class StoryViewControllerSnapshotTests: XCTestCase {
    func test_details_story() {
        let cell = StoryCellController(viewModel: StoryDetailViewModel(
            title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
            author: "dhouston",
            score: "111 points",
            comments: "0 comments",
            createdAt: "27 years ago",
            displayURL: "getdropbox.com"
        ))
        let sut = StoryDetailsViewController(storyCellController: cell)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "story_details_dark")
    }

    func test_details_ask() {
        let cell = StoryCellController(viewModel: StoryDetailViewModel(
            title: "Ask HN: The Arc Effect",
            author: "tel",
            score: "25 points",
            comments: "13 comments",
            createdAt: "30 minutes ago",
            displayURL: nil
        ))
        let sut = StoryDetailsViewController(storyCellController: cell)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "ask_story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "ask_story_details_dark")
    }

    func test_details_job() {
        let cell = StoryCellController(viewModel: StoryDetailViewModel(
            title: "Justin.tv is looking for a Lead Flash Engineer!",
            author: "justin",
            score: "6 points",
            comments: nil,
            createdAt: "30 minutes ago",
            displayURL: nil
        ))
        let sut = StoryDetailsViewController(storyCellController: cell)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "job_story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "job_story_details_dark")
    }

    func test_details_poll() {
        let cell = StoryCellController(viewModel: StoryDetailViewModel(
            title: "Poll: What would happen if News.YC had explicit support for polls?",
            author: "pg",
            score: "46 points",
            comments: "100 comments",
            createdAt: "30 minutes ago",
            displayURL: nil
        ))
        let sut = StoryDetailsViewController(storyCellController: cell)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "poll_story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "poll_story_details_dark")
    }
}
