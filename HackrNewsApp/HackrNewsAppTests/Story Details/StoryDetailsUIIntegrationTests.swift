//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import HackrNewsiOS
import XCTest

final class StoryDetailsUIIntegrationTests: XCTestCase {
    func test_controllerTopStories_hasTitle() {
        let (sut, _) = makeSUT(story: makeStoryDetail())

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, StoryDetailsPresenter.title)
    }

    func test_commentsSection_hasTitle() {
        let (sut, _) = makeSUT(story: makeStoryDetail())

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.commentsTitle, StoryDetailsPresenter.title)
    }

    func test_viewDidLoad_displaysStory() {
        let fixedDate = Date().adding(days: -1)
        let story = makeStoryDetail(
            title: "a title",
            text: "a text",
            author: "an author",
            createdAt: fixedDate,
            url: URL(string: "https://a-url.com")!
        )
        let (sut, _) = makeSUT(story: story)

        sut.loadViewIfNeeded()

        assert(sut, isDisplaying: story)
    }

    func test_viewDidLoad_displaysStoryWithoutBodyContent() {
        let (sut, _) = makeSUT(story: makeStoryDetail(text: nil))

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.bodyText, nil)
    }

    func test_detailCell_isReusableWhenNotVisibleAnymore() {
        let (sut, _) = makeSUT(story: makeStoryDetail())
        sut.loadViewIfNeeded()

        sut.simulateStoryDetailViewVisible()
        XCTAssertFalse(sut.detailViewIsReusable)

        sut.simulateStoryDetailViewNotVisible()
        XCTAssertTrue(sut.detailViewIsReusable, "Expected release cell when view is not visible")
    }

    func test_viewDidLoad_displaysMainComments() {
        let story = makeStoryDetail(comments: [1, 2, 3])
        let (sut, loader) = makeSUT(story: story)

        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedComments(), 3, "Expected to display 3 comments")

        let view = sut.simulateCommentViewVisible(at: 0)
        XCTAssertEqual(view?.isLoadingContent, true, "Expected start loading content")

        loader.complete(with: StoryComment(
            id: 1,
            author: "a comment author",
            comments: [],
            parent: 0,
            text: "a text comment",
            createdAt: Date().adding(days: -1),
            type: "comment"
        ))
        XCTAssertEqual(view?.isLoadingContent, false, "Expected stop loading content")

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

    private func makeStoryDetail(
        title: String = "title",
        text: String? = "text",
        author: String = "author",
        createdAt _: Date = Date(),
        comments: [Int] = [],
        url: URL = anyURL()
    ) -> StoryDetail {
        StoryDetail(
            title: title,
            text: text,
            author: author,
            score: Int.random(in: 0 ... 100),
            createdAt: Date(),
            totalComments: Int.random(in: 0 ... 100),
            comments: comments,
            url: url
        )
    }

    private func assert(_ sut: StoryDetailsViewController, isDisplaying story: StoryDetail) {
        let viewModel = StoryDetailsPresenter.map(story)
        XCTAssertEqual(sut.titleText, viewModel.title)
        XCTAssertEqual(sut.authorText, viewModel.author)
        XCTAssertEqual(sut.bodyText, viewModel.text)
        XCTAssertEqual(sut.scoreText, viewModel.score)
        XCTAssertEqual(sut.commentsText, viewModel.comments)
        XCTAssertEqual(sut.createdAtText, viewModel.createdAt)
        XCTAssertEqual(sut.urlText, viewModel.displayURL)
    }

    private class CommentLoaderSpy: CommentLoader {
        var completions = [(CommentLoader.Result) -> Void]()

        var loadCallCount: Int { completions.count }

        func load(completion: @escaping (CommentLoader.Result) -> Void) {
            completions.append(completion)
        }

        func complete(with comment: StoryComment, at index: Int = 0) {
            completions[index](.success(comment))
        }
    }
}
