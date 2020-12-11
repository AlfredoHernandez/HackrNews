//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct NewStoriesErrorViewModel {
    public let message: String?

    public static var noErrorMessage: NewStoriesErrorViewModel {
        NewStoriesErrorViewModel(message: nil)
    }
}

public protocol NewStoriesErrorView {
    func display(_ viewModel: NewStoriesErrorViewModel)
}

public struct NewStoriesLoadingViewModel {
    public let isLoading: Bool
}

public protocol NewStoriesLoadingView {
    func display(_ viewModel: NewStoriesLoadingViewModel)
}

public struct NewStoriesViewModel {
    public let stories: [LiveHackerNew]
}

public protocol NewStoriesView {
    func display(_ viewModel: NewStoriesViewModel)
}

public class NewStoriesPresenter {
    private let view: NewStoriesView
    private let loadingView: NewStoriesLoadingView
    private let errorView: NewStoriesErrorView

    public static var title: String {
        NSLocalizedString(
            "new_stories_title",
            tableName: "NewStories",
            bundle: Bundle(for: NewStoriesPresenter.self),
            value: "",
            comment: "New Stories title view"
        )
    }

    public init(view: NewStoriesView, loadingView: NewStoriesLoadingView, errorView: NewStoriesErrorView) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoadingStories() {
        loadingView.display(NewStoriesLoadingViewModel(isLoading: true))
        errorView.display(.noErrorMessage)
    }

    public func didFinishLoadingStories(stories: [LiveHackerNew]) {
        loadingView.display(NewStoriesLoadingViewModel(isLoading: false))
        view.display(NewStoriesViewModel(stories: stories))
    }
}
