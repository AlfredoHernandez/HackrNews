//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryViewModel: Equatable {
    public let newId: Int
    public let title: String?
    public let author: String?
    public let comments: String?
    public let score: String?
    public let date: String?

    public init(newId: Int, title: String?, author: String?, comments: String?, score: String?, date: String?) {
        self.newId = newId
        self.title = title
        self.author = author
        self.comments = comments
        self.score = score
        self.date = date
    }
}

public protocol StoryView {
    func display(_ viewModel: StoryViewModel)
}

public struct StoryLoadingViewModel {
    public let isLoading: Bool
}

public protocol StoryLoadingView {
    func display(_ viewModel: StoryLoadingViewModel)
}

public struct StoryErrorViewModel {
    public let message: String?

    public init(message: String?) {
        self.message = message
    }
}

public protocol StoryErrorView {
    func display(_ viewModel: StoryErrorViewModel)
}

public final class StoryPresenter {
    private let view: StoryView
    private let loadingView: StoryLoadingView
    private let errorView: StoryErrorView
    private var locale = Locale.current
    private var calendar = Calendar(identifier: .gregorian)
    private var errorMessage: String {
        NSLocalizedString(
            "story_error_message",
            tableName: "Story",
            bundle: Bundle(for: StoryPresenter.self),
            value: "",
            comment: "Story Error message"
        )
    }

    private var score: String {
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
        self.locale = locale
        self.calendar = calendar
    }

    public func didStartLoadingStory(from new: LiveHackrNew) {
        loadingView.display(StoryLoadingViewModel(isLoading: true))
        view.display(StoryViewModel(newId: new.id, title: nil, author: nil, comments: nil, score: nil, date: nil))
        errorView.display(StoryErrorViewModel(message: nil))
    }

    public func didFinishLoadingStory(story: Story) {
        loadingView.display(StoryLoadingViewModel(isLoading: false))
        view.display(StoryViewModel(
            newId: story.id,
            title: story.title,
            author: story.author,
            comments: story.comments.count.description,
            score: String(format: score, story.score),
            date: format(from: story.createdAt)
        ))
        errorView.display(StoryErrorViewModel(message: nil))
    }

    public func didFinishLoading(with _: Error) {
        loadingView.display(StoryLoadingViewModel(isLoading: false))
        errorView.display(StoryErrorViewModel(message: errorMessage))
    }

    private func format(from date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
}
