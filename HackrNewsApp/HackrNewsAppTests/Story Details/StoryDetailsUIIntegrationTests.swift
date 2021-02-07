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

    func test_loadCommentActions_doesNotRequestCommentsFromLoader() {
        let (sut, loader) = makeSUT(story: makeStoryDetail(comments: []))

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before display comments")

        let view = sut.simulateCommentViewVisible()
        XCTAssertNil(view, "Should not display a comment view")
    }

    func test_loadCommentActions_requestsCommentFromLoader() {
        let (sut, loader) = makeSUT(story: makeStoryDetail(comments: [1, 2, 3]))

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before display comments")

        sut.simulateCommentViewVisible(at: 0)
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loding request after comment view is displayed")

        sut.simulateCommentViewVisible(at: 1)
        XCTAssertEqual(loader.loadCallCount, 2, "Expected a loding request after comment view is displayed")

        sut.simulateCommentViewVisible(at: 2)
        XCTAssertEqual(loader.loadCallCount, 3, "Expected a loding request after comment view is displayed")
    }

    func test_requestComments_displaysLoaderComments() {
        let story = makeStoryDetail(comments: [1, 2])
        let (sut, loader) = makeSUT(story: story)
        sut.loadViewIfNeeded()

        let view0 = sut.simulateCommentViewVisible(at: 0)
        XCTAssertEqual(view0?.isLoadingContent, true, "Expected v0 start loading content")

        loader.complete(with: makeStoryComment(), at: 0)
        XCTAssertEqual(view0?.isLoadingContent, false, "Expected v0 stop loading content")
    }

    func test_viewDidLoad_displaysMainComments() {
        let story = makeStoryDetail(comments: [1, 2])
        let (sut, loader) = makeSUT(story: story)
        let comment0 = StoryComment(
            id: 1,
            author: "a comment author",
            comments: [],
            parent: 0,
            text: "a text comment",
            createdAt: Date().adding(days: -1),
            type: "comment"
        )

        let comment1 = StoryComment(
            id: 2,
            author: "another comment author",
            comments: [],
            parent: 0,
            text: "another text comment",
            createdAt: Date().adding(days: -2),
            type: "comment"
        )

        sut.loadViewIfNeeded()

        assertThat(sut, isRendering: [comment0, comment1], loader: loader)
    }

    func test_commentView_preloadsCommentWhenIsNearVisible() {
        let story = makeStoryDetail(comments: [1, 2])
        let (sut, loader) = makeSUT(story: story)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 0)

        sut.simulateCommentViewIsNearVisible(at: 0)
        XCTAssertEqual(loader.loadCallCount, 1)

        sut.simulateCommentViewIsNearVisible(at: 1)
        XCTAssertEqual(loader.loadCallCount, 2)
    }

    func test_commentView_cancelsPreloadingCommentWhenIsNotNearVisibleAnymore() {
        let story = makeStoryDetail(comments: [1])
        let (sut, loader) = makeSUT(story: story)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 0)

        sut.simulateCommentViewVisible(at: 0)
        XCTAssertEqual(loader.loadCallCount, 1)

        sut.simulateCommentViewIsNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledRequests, 1)
    }

    func test_commentView_doesNotRenderCommentWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT(story: makeStoryDetail(comments: [1]))

        sut.loadViewIfNeeded()

        let view = sut.simulateCommentViewNotVisible()

        loader.complete(with: makeStoryComment(), at: 0)
        XCTAssertEqual(view?.authorText, CommentCell.defaultAuthorText, "Expected `\(CommentCell.defaultAuthorText)` default text in view")
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

    private func makeStoryComment() -> StoryComment {
        StoryComment(
            id: Int.random(in: 0 ... 100),
            author: "author",
            comments: [],
            parent: 0,
            text: "text",
            createdAt: Date(),
            type: "comment"
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

    private func assertThat(
        _ sut: StoryDetailsViewController,
        isRendering comments: [StoryComment],
        loader: CommentLoaderSpy,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedComments() == comments.count else {
            return XCTFail("Expected \(comments.count) comments, got \(sut.numberOfRenderedComments()) instead.", file: file, line: line)
        }
        comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfiguredFor: comment, loader: loader, at: index)
        }
    }

    private func assertThat(
        _ sut: StoryDetailsViewController,
        hasViewConfiguredFor comment: StoryComment,
        loader: CommentLoaderSpy,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.commentView(at: index) as? CommentCell
        guard let cell = view else {
            return XCTFail("Expected \(CommentCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }

        loader.complete(with: comment, at: index)

        let viewModel = CommentPresenter.map(comment)
        XCTAssertEqual(cell.authorLabel.text, viewModel.author, file: file, line: line)
        XCTAssertEqual(cell.createdAtLabel.text, viewModel.createdAt, file: file, line: line)
        XCTAssertEqual(cell.bodyLabel.text, viewModel.text, file: file, line: line)
    }

    private class CommentLoaderSpy: CommentLoader {
        var completions = [(CommentLoader.Result) -> Void]()

        class WrappedTask: CommentLoaderTask {
            private let completion: () -> Void

            init(completion: @escaping () -> Void) {
                self.completion = completion
            }

            func cancel() {
                completion()
            }
        }

        var loadCallCount: Int { completions.count }

        var cancelledRequests = 0

        func load(completion: @escaping (CommentLoader.Result) -> Void) -> CommentLoaderTask {
            completions.append(completion)

            return WrappedTask { [weak self] in
                self?.cancelledRequests += 1
            }
        }

        func complete(with comment: StoryComment, at index: Int = 0) {
            completions[index](.success(comment))
        }
    }
}
