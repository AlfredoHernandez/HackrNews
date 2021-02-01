//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import HackrNewsiOS
import XCTest

final class StoryDetailsViewControllerIntegrationTests: XCTestCase {
    func test_controllerTopStories_hasTitle() {
        let (sut, _) = makeSUT(story: anyStoryDetail())

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, StoryDetailsPresenter.title)
    }

    func test_commentsSection_hasTitle() {
        let (sut, _) = makeSUT(story: anyStoryDetail())

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
        let (sut, _) = makeSUT(story: story)

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
        let (sut, _) = makeSUT(story: anyStoryDetail(withBody: false))

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.bodyText, nil)
    }

    func test_detailCell_isReusableWhenNotVisibleAnymore() {
        let (sut, _) = makeSUT(story: anyStoryDetail())
        sut.loadViewIfNeeded()

        sut.simulateStoryDetailViewVisible()
        XCTAssertFalse(sut.detailViewIsReusable)

        sut.simulateStoryDetailViewNotVisible()
        XCTAssertTrue(sut.detailViewIsReusable, "Expected release cell when view is not visible")
    }

    func test_viewDidLoad_displaysMainComments() {
        let story = StoryDetail(
            title: "a title",
            text: "a text",
            author: "an author",
            score: 10,
            createdAt: Date(),
            totalComments: 34,
            comments: [1, 2, 3],
            url: anyURL()
        )
        let (sut, loader) = makeSUT(story: story)

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedComments(), 3, "Expected to display 3 comments")

        let view = sut.simulateCommentViewVisible(at: 0)
        loader.complete(with: StoryComment(
            id: 1,
            author: "a comment author",
            comments: [],
            parent: 0,
            text: "a text comment",
            createdAt: Date().adding(days: -1),
            type: "comment"
        ))
        XCTAssertNotNil(view, "Expected \(CommentCell.self) instance, got \(String(describing: view)) instead")
        XCTAssertEqual(view?.authorLabel.text, "a comment author")
        XCTAssertEqual(view?.createdAtLabel.text, "1 day ago")
        XCTAssertEqual(view?.authorLabel.text, "a comment author")
    }

    // MARK: - Helpers

    private func makeSUT(
        story: StoryDetail,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (StoryDetailsViewController, CommentLoaderSpy) {
        let loader = CommentLoaderSpy()
        let sut = StoryDetailsUIComposer.composeWith(model: story, loader: { _ in loader })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }

    private class CommentLoaderSpy: CommentLoader {
        var completions = [(CommentLoader.Result) -> Void]()

        func load(completion: @escaping (CommentLoader.Result) -> Void) {
            completions.append(completion)
        }

        func complete(with comment: StoryComment, at index: Int = 0) {
            completions[index](.success(comment))
        }
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
