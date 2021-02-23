//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryViewModel: Equatable {
    public let newId: Int
    public let title: String?
    public let author: String?
    public let comments: String?
    public let score: String?
    public let date: String?
    public let url: URL?
    public let displayURL: String?

    public init(
        newId: Int,
        title: String?,
        author: String?,
        comments: String?,
        score: String?,
        date: String?,
        url: URL?,
        displayURL: String?
    ) {
        self.newId = newId
        self.title = title
        self.author = author
        self.comments = comments
        self.score = score
        self.date = date
        self.url = url
        self.displayURL = displayURL
    }
}

public protocol StoryView {
    func display(_ viewModel: StoryViewModel)
}

public struct StoryLoadingViewModel {
    public let isLoading: Bool

    static let loading = StoryLoadingViewModel(isLoading: true)
    static let stoped = StoryLoadingViewModel(isLoading: false)
}

public protocol StoryLoadingView {
    func display(_ viewModel: StoryLoadingViewModel)
}

public struct StoryErrorViewModel {
    public let error: String?

    public init(error: String?) {
        self.error = error
    }

    static let none = StoryErrorViewModel(error: nil)
}

public protocol StoryErrorView {
    func display(_ viewModel: StoryErrorViewModel)
}

public final class StoryPresenter {
    private let view: StoryView
    private let loadingView: StoryLoadingView
    private let errorView: StoryErrorView
    private static var locale = Locale.current
    private static var calendar = Calendar(identifier: .gregorian)
    private var errorMessage: String {
        NSLocalizedString(
            "story_error_message",
            tableName: "Story",
            bundle: Bundle(for: StoryPresenter.self),
            value: "",
            comment: "Story Error message"
        )
    }

    private static var comments: String {
        NSLocalizedString(
            "story_comments_message",
            tableName: "Story",
            bundle: Bundle(for: StoryPresenter.self),
            value: "",
            comment: "Story comments text label"
        )
    }

    private static var score: String {
        NSLocalizedString(
            "story_points_message",
            tableName: "Story",
            bundle: Bundle(for: StoryPresenter.self),
            value: "",
            comment: "Story score text label"
        )
    }

    public init(
        view: StoryView,
        loadingView: StoryLoadingView,
        errorView: StoryErrorView,
        locale: Locale = Locale.current,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
        Self.locale = locale
        Self.calendar = calendar
    }

    public func didStartLoadingStory(from _: HackrNew) {
        loadingView.display(.loading)
        errorView.display(.none)
    }

    public func didFinishLoadingStory(story: Story) {
        loadingView.display(.stoped)
        view.display(Self.map(story: story))
        errorView.display(.none)
    }

    public func didFinishLoading(with _: Error) {
        loadingView.display(StoryLoadingViewModel(isLoading: false))
        errorView.display(StoryErrorViewModel(error: errorMessage))
    }

    private static func format(from date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }

    public static func map(story: Story) -> StoryViewModel {
        StoryViewModel(
            newId: story.id,
            title: story.title,
            author: story.author,
            comments: String(format: comments, story.totalComments ?? 0),
            score: String(format: score, story.score ?? "0"),
            date: format(from: story.createdAt),
            url: story.url,
            displayURL: story.url?.host
        )
    }
}
