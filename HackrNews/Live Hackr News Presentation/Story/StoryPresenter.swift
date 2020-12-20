//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryViewModel: Equatable {
    public let newId: Int
    public let title: String?
    public let author: String?
    public let comments: Int?
    public let date: String?
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
}

public protocol StoryErrorView {
    func display(_ viewModel: StoryErrorViewModel)
}

public final class StoryPresenter {
    private let view: StoryView
    private let loadingView: StoryLoadingView
    private let errorView: StoryErrorView
    public var locale = Locale.current
    public var calendar = Calendar(identifier: .gregorian)
    private var errorMessage: String {
        NSLocalizedString("story_error_message", tableName: "Story", bundle: Bundle(for: StoryPresenter.self), value: "", comment: "Story Error message")
    }

    public init(view: StoryView, loadingView: StoryLoadingView, errorView: StoryErrorView) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoadingStory(from new: LiveHackrNew) {
        loadingView.display(StoryLoadingViewModel(isLoading: true))
        view.display(StoryViewModel(newId: new.id, title: nil, author: nil, comments: nil, date: nil))
        errorView.display(StoryErrorViewModel(message: nil))
    }

    public func didStopLoadingStory(story: Story) {
        loadingView.display(StoryLoadingViewModel(isLoading: false))
        view.display(StoryViewModel(
            newId: story.id,
            title: story.title,
            author: story.author,
            comments: story.comments.count,
            date: format(from: story.createdAt, locale: locale, calendar: calendar)
        ))
        errorView.display(StoryErrorViewModel(message: nil))
    }

    public func didFinishLoading(with error: Error) {
        loadingView.display(StoryLoadingViewModel(isLoading: false))
        errorView.display(StoryErrorViewModel(message: errorMessage))
    }
    
    private func format(
        from date: Date,
        locale _: Locale = Locale.current,
        calendar _: Calendar = Calendar(identifier: .gregorian)
    ) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
}
