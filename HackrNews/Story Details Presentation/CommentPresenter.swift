//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct CommentErrorViewModel {
    public let error: String?
    static let none = CommentErrorViewModel(error: nil)

    public init(error: String?) {
        self.error = error
    }
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
    public let text: String?
    public let createdAt: String

    public init(author: String, text: String?, createdAt: String) {
        self.author = author
        self.text = text
        self.createdAt = createdAt
    }
}

public protocol CommentView {
    func display(_ viewModel: CommentViewModel)
}

public class CommentPresenter {
    private let view: CommentView
    private let loadingView: CommentLoadingView
    private let errorView: CommentErrorView

    public init(
        view: CommentView,
        loadingView: CommentLoadingView,
        errorView: CommentErrorView
    ) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }

    let errorMessage =
        NSLocalizedString(
            "loading_comment_error_message",
            tableName: "StoryDetails",
            bundle: Bundle(for: StoryDetailsPresenter.self),
            value: "",
            comment: "Comment loading error message"
        )

    public static let commentDeleted =
        NSLocalizedString(
            "story_details_comment_deleted",
            tableName: "StoryDetails",
            bundle: Bundle(for: StoryDetailsPresenter.self),
            value: "",
            comment: "Comment deleted message"
        )

    public func didStartLoadingComment() {
        loadingView.display(.loading)
        errorView.display(.none)
    }

    public func didFinishLoadingComment(
        with comment: StoryComment,
        calendar: Calendar = Calendar(identifier: .gregorian),
        locale: Locale = .current
    ) {
        loadingView.display(.stoped)
        view.display(Self.map(comment, calendar: calendar, locale: locale))
    }

    public func didFinishLoadingComment(with _: Error) {
        loadingView.display(.stoped)
        errorView.display(CommentErrorViewModel(error: errorMessage))
    }

    public static func map(
        _ comment: StoryComment,
        against: Date = Date(),
        calendar: Calendar = Calendar(identifier: .gregorian),
        locale: Locale = .current
    ) -> CommentViewModel {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        return CommentViewModel(
            author: comment.author ?? commentDeleted,
            text: comment.text,
            createdAt: formatter.localizedString(for: comment.createdAt, relativeTo: against)
        )
    }
}
