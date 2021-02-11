//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class CommentPresentationTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages upon creation")
    }

    func test_didStartLoadingComment_displaysLoader() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingComment()

        XCTAssertEqual(view.messages, [.display(isLoading: true), .display(error: .none)])
    }

    func test_didFinishLoadingComment_hidesLoaderAndDisplaysComment() {
        let calendar = Calendar(identifier: .gregorian)
        let locale: Locale = .current
        let (sut, view) = makeSUT()
        let comment = StoryComment(
            id: 1,
            deleted: false,
            author: "an author",
            comments: [],
            parent: 0,
            text: "a text",
            createdAt: Date().adding(min: -1),
            type: "comment"
        )
        sut.didFinishLoadingComment(with: comment, calendar: calendar, locale: locale)

        XCTAssertEqual(
            view.messages,
            [
                .display(isLoading: false),
                .display(author: "an author", text: "a text", createdAt: "1 minute ago"),
            ]
        )
    }

    func test_didFinishLoadingDeletedComment_hidesLoaderAndDisplaysComment() {
        let calendar = Calendar(identifier: .gregorian)
        let locale: Locale = .current
        let (sut, view) = makeSUT()
        let deletedComment = StoryComment(
            id: 1,
            deleted: true,
            author: nil,
            comments: [],
            parent: 0,
            text: nil,
            createdAt: Date().adding(min: -5),
            type: "comment"
        )

        sut.didFinishLoadingComment(with: deletedComment, calendar: calendar, locale: locale)

        XCTAssertEqual(
            view.messages,
            [
                .display(isLoading: false),
                .display(
                    author: localized("story_details_comment_deleted"),
                    text: nil,
                    createdAt: "5 minutes ago"
                ),
            ]
        )
    }

    func test_didFinishLoadingCommentWithError_displaysErrorAndStopsLoadint() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingComment(with: anyNSError())

        XCTAssertEqual(view.messages, [.display(isLoading: false), .display(error: localized("loading_comment_error_message"))])
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (CommentPresenter, CommentViewSpy) {
        let view = CommentViewSpy()
        let sut = CommentPresenter(view: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "StoryDetails"
        let bundle = Bundle(for: StoryDetailsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }

    private class CommentViewSpy: CommentView, CommentLoadingView, CommentErrorView {
        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(author: String, text: String?, createdAt: String)
            case display(error: String?)
        }

        var messages = [Message]()

        func display(_ viewModel: CommentLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: CommentViewModel) {
            messages.append(.display(author: viewModel.author, text: viewModel.text, createdAt: viewModel.createdAt))
        }

        func display(_ viewModel: CommentErrorViewModel) {
            messages.append(.display(error: viewModel.error))
        }
    }
}
