//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

struct CommentErrorViewModel {
    let error: String?
    static let none = CommentErrorViewModel(error: nil)
}

protocol CommentErrorView {
    func display(_ viewModel: CommentErrorViewModel)
}

struct CommentLoadingViewModel {
    let isLoading: Bool

    static let loading = CommentLoadingViewModel(isLoading: true)
    static let stoped = CommentLoadingViewModel(isLoading: false)
}

protocol CommentLoadingView {
    func display(_ viewModel: CommentLoadingViewModel)
}

struct CommentViewModel {
    let author: String
    let text: String
    let createdAt: String
}

protocol CommentView {
    func display(_ viewModel: CommentViewModel)
}

class CommentPresenter {
    private let calendar: Calendar
    private let locale: Locale
    private let view: CommentView
    private let loadingView: CommentLoadingView
    private let errorView: CommentErrorView

    init(
        view: CommentView,
        loadingView: CommentLoadingView,
        errorView: CommentErrorView,
        calendar: Calendar = Calendar(identifier: .gregorian),
        locale: Locale = .current
    ) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
        self.calendar = calendar
        self.locale = locale
    }

    let errorMessage =
        NSLocalizedString(
            "loading_comment_error_message",
            tableName: "StoryDetails",
            bundle: Bundle(for: StoryDetailsPresenter.self),
            value: "",
            comment: "Comment loading error message"
        )

    func didStartLoadingComment() {
        loadingView.display(.loading)
        errorView.display(.none)
    }

    func didFinishLoadingComment(with comment: StoryComment) {
        loadingView.display(.stoped)
        view.display(CommentViewModel(author: comment.author, text: comment.text, createdAt: formatDate(from: comment.createdAt)))
    }

    func didFinishLoadingComment(with _: Error) {
        loadingView.display(.stoped)
        errorView.display(CommentErrorViewModel(error: errorMessage))
    }

    private func formatDate(from date: Date, against: Date = Date()) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        return formatter.localizedString(for: date, relativeTo: against)
    }
}

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
        let (sut, view) = makeSUT(calendar: calendar, locale: locale)
        let comment = StoryComment(
            id: 1,
            author: "an author",
            comments: [],
            parent: 0,
            text: "a text",
            createdAt: Date().adding(min: -1),
            type: "comment"
        )

        sut.didFinishLoadingComment(with: comment)

        XCTAssertEqual(
            view.messages,
            [.display(isLoading: false), .display(author: "an author", text: "a text", createdAt: "1 minute ago")]
        )
    }

    func test_didFinishLoadingCommentWithError_displaysErrorAndStopsLoadint() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingComment(with: anyNSError())

        XCTAssertEqual(view.messages, [.display(isLoading: false), .display(error: localized("loading_comment_error_message"))])
    }

    // MARK: - Helpers

    private func makeSUT(
        calendar: Calendar = Calendar(identifier: .gregorian),
        locale: Locale = .current,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (CommentPresenter, CommentViewSpy) {
        let view = CommentViewSpy()
        let sut = CommentPresenter(view: view, loadingView: view, errorView: view, calendar: calendar, locale: locale)
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
            case display(author: String, text: String, createdAt: String)
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
