//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsiOS
import XCTest

final class StoryViewControllerSnapshotTests: XCTestCase {
    func test_details_story() {
        let viewModel = StoryDetailViewModel(
            title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
            text: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
            author: "dhouston",
            score: "111 points",
            comments: "0 comments",
            createdAt: "27 years ago",
            displayURL: "getdropbox.com"
        )
        let sut = makeSUT(viewModel: viewModel)

        sut.loadViewIfNeeded()

        sut.display([
            CommentStub(author: "alfredo", text: "This is a single line comment", createdAt: "2 minutes ago"),
            CommentStub(
                author: "john_doe",
                text: "Sed ut perspiciatis unde omnis <p>iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis <p><pre>et quasi architecto beatae vitae dicta sunt explicabo</pre>.</p><br/><p>Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt</p>",
                createdAt: "1 year ago"
            ),
        ])

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "story_details_dark")
    }

    func test_details_without_text_story() {
        let viewModel = StoryDetailViewModel(
            title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua",
            text: nil,
            author: "dhouston",
            score: "111 points",
            comments: "0 comments",
            createdAt: "27 years ago",
            displayURL: "getdropbox.com"
        )
        let sut = makeSUT(viewModel: viewModel)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "story_details_without_text_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "story_details_without_text_dark")
    }

    func test_details_ask() {
        let viewModel = StoryDetailViewModel(
            title: "Ask HN: The Arc Effect",
            text: nil,
            author: "tel",
            score: "25 points",
            comments: "13 comments",
            createdAt: "30 minutes ago",
            displayURL: nil
        )
        let sut = makeSUT(viewModel: viewModel)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "ask_story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "ask_story_details_dark")
    }

    func test_details_job() {
        let viewModel = StoryDetailViewModel(
            title: "Justin.tv is looking for a Lead Flash Engineer!",
            text: nil,
            author: "justin",
            score: "6 points",
            comments: nil,
            createdAt: "30 minutes ago",
            displayURL: nil
        )
        let sut = makeSUT(viewModel: viewModel)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "job_story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "job_story_details_dark")
    }

    func test_details_poll() {
        let viewModel = StoryDetailViewModel(
            title: "Poll: What would happen if News.YC had explicit support for polls?",
            text: nil,
            author: "pg",
            score: "46 points",
            comments: "100 comments",
            createdAt: "30 minutes ago",
            displayURL: nil
        )
        let sut = makeSUT(viewModel: viewModel)

        sut.loadViewIfNeeded()

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "poll_story_details_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "poll_story_details_dark")
    }

    // MARK: - Helpers

    private func makeSUT(viewModel: StoryDetailViewModel) -> StoryDetailsViewController {
        let cell = StoryCellController(viewModel: viewModel)
        let bodyComment = viewModel.text != nil ? BodyCommentCellController(body: viewModel.text) : nil
        let sut = StoryDetailsViewController(storyCellController: cell, bodyCommentCellController: bodyComment)
        return sut
    }
}

private extension StoryDetailsViewController {
    func display(_ stubs: [CommentStub]) {
        let controllers = stubs.map { stub -> CommentCellController in
            let controller = CommentCellController(delegate: stub)
            stub.controller = controller
            return controller
        }
        display(controllers)
    }
}

private class CommentStub: CommentCellControllerDelegate {
    weak var controller: CommentCellController?
    let viewModel: CommentViewModel

    init(author: String, text: String, createdAt: String) {
        viewModel = CommentViewModel(author: author, text: text, createdAt: createdAt)
    }

    func didRequestComment() {
        controller?.display(viewModel)
    }

    func didCancelRequest() {}
}
