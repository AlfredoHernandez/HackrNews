//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

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

    private var errorMessage: String {
        NSLocalizedString(
            "new_stories_error_message",
            tableName: "NewStories",
            bundle: Bundle(for: NewStoriesPresenter.self),
            value: "",
            comment: "New Stories loading error message"
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

    public func didFinishLoadingStories(stories: [LiveHackrNew]) {
        loadingView.display(NewStoriesLoadingViewModel(isLoading: false))
        view.display(NewStoriesViewModel(stories: stories))
    }

    public func didFinishLoadingStories(with _: Error) {
        loadingView.display(NewStoriesLoadingViewModel(isLoading: false))
        errorView.display(NewStoriesErrorViewModel(message: errorMessage))
    }
}
