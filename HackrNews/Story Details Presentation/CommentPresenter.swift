//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct CommentErrorViewModel {
    public let error: String?
    static let none = CommentErrorViewModel(error: nil)
}

public protocol CommentErrorView {
    func display(_ viewModel: CommentErrorViewModel)
}

public struct CommentLoadingViewModel {
    public let isLoading: Bool

    static let loading = CommentLoadingViewModel(isLoading: true)
    static let stoped = CommentLoadingViewModel(isLoading: false)
}

public protocol CommentLoadingView {
    func display(_ viewModel: CommentLoadingViewModel)
}

public struct CommentViewModel {
    public let author: String
    public let text: String
    public let createdAt: String

    public init(author: String, text: String, createdAt: String) {
        self.author = author
        self.text = text
        self.createdAt = createdAt
    }
}

public protocol CommentView {
    func display(_ viewModel: CommentViewModel)
}

public class CommentPresenter {
    private let calendar: Calendar
    private let locale: Locale
    private let view: CommentView
    private let loadingView: CommentLoadingView
    private let errorView: CommentErrorView

    public init(
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

    public func didStartLoadingComment() {
        loadingView.display(.loading)
        errorView.display(.none)
    }

    public func didFinishLoadingComment(with comment: StoryComment) {
        loadingView.display(.stoped)
        view.display(CommentViewModel(author: comment.author, text: comment.text, createdAt: formatDate(from: comment.createdAt)))
    }

    public func didFinishLoadingComment(with _: Error) {
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
