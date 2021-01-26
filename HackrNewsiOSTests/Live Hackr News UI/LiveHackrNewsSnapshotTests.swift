//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import XCTest

final class LiveHackrNewsSnapshotTests: XCTestCase {
    func test_emptyStories() {
        let sut = makeSUT()

        sut.display(HackrNewsFeedErrorViewModel(message: .none))
        sut.display(emptyStories())

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "empty_stories_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "empty_stories_dark")
    }

    func test_displaysStories() {
        let sut = makeSUT()

        sut.display(feedStories(stubs: [
            StoryStub(
                id: 1,
                title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                author: "a-large-username",
                comments: "6 comments",
                score: "65 points",
                date: "Dec 20, 2020",
                displayURL: "any-url.com"
            ),
            StoryStub(
                id: 2,
                title: "Sed ut perspiciatis",
                author: "a-user",
                comments: "45K comments",
                score: "0 points",
                date: "Dec 18, 2020",
                displayURL: "another-url.com"
            ),
            StoryStub(
                id: 3,
                title: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
                author: "another-large-username",
                comments: "20 comments",
                score: "37 points",
                date: "Dec 2, 2020",
                displayURL: "a-large-url-that-should-display-correctly.com"
            ),
            StoryStub(
                id: 4,
                title: "Sed ut perspiciatis",
                author: "user",
                comments: "1M comments",
                score: "5 points",
                date: "Nov 3, 2020",
                displayURL: "a.com"
            ),
        ]))

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "stories_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "stories_dark")
    }

    func test_storiesWithStoryFailed() {
        let sut = makeSUT()

        sut.display(feedStories(stubs: [
            StoryStub(id: 1, title: nil, author: nil, comments: nil, score: nil, date: nil, displayURL: nil, error: anyNSError()),
            StoryStub(id: 2, title: nil, author: nil, comments: nil, score: nil, date: nil, displayURL: nil, error: anyNSError()),
            StoryStub(id: 3, title: nil, author: nil, comments: nil, score: nil, date: nil, displayURL: nil, error: anyNSError()),
            StoryStub(id: 4, title: nil, author: nil, comments: nil, score: nil, date: nil, displayURL: nil, error: anyNSError()),
        ]))

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "storie_failed_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "stories_failed_dark")
    }

    // MARK: - Helpers

    private func makeSUT() -> LiveHackrNewsViewController {
        let controller = LiveHackrNewsViewController()
        controller.tableView.showsVerticalScrollIndicator = false
        return controller
    }

    private func emptyStories() -> [LiveHackrNewCellController] { [] }

    private func anyNSError() -> NSError {
        NSError(domain: "", code: 0, userInfo: nil)
    }

    private func feedStories(stubs: [StoryStub]) -> [LiveHackrNewCellController] {
        stubs.map { stub in
            let controller = LiveHackrNewCellController(delegate: stub, didSelectStory: { _ in })
            stub.controller = controller
            return controller
        }
    }

    private class StoryStub: LiveHackrNewCellControllerDelegate {
        let viewModel: StoryViewModel
        var errorViewModel: StoryErrorViewModel?
        weak var controller: LiveHackrNewCellController?

        init(
            id: Int,
            title: String?,
            author: String?,
            comments: String?,
            score: String?,
            date: String?,
            displayURL: String?,
            error: Error? = nil
        ) {
            viewModel = StoryViewModel(
                newId: id,
                title: title,
                author: author,
                comments: comments,
                score: score,
                date: date,
                url: nil,
                displayURL: displayURL
            )
            if error != nil {
                errorViewModel = StoryErrorViewModel(message: "any error message")
            }
        }

        func didRequestStory() {
            if let errorVM = errorViewModel {
                controller?.display(errorVM)
            } else {
                controller?.display(viewModel)
            }
        }

        func didCancelRequest() {}
    }
}
