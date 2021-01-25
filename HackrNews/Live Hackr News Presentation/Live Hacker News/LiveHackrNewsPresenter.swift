//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class LiveHackrNewsPresenter {
    private let view: LiveHackrNewsView
    private let loadingView: LiveHackrNewsLoadingView
    private let errorView: LiveHackrNewsErrorView

    public static var topStoriesTitle: String {
        NSLocalizedString(
            "top_stories_title",
            tableName: "LiveHackrNews",
            bundle: Bundle(for: LiveHackrNewsPresenter.self),
            value: "",
            comment: "Top Stories title view"
        )
    }

    public static var newStoriesTitle: String {
        NSLocalizedString(
            "new_stories_title",
            tableName: "LiveHackrNews",
            bundle: Bundle(for: LiveHackrNewsPresenter.self),
            value: "",
            comment: "New Stories title view"
        )
    }

    public static var bestStoriesTitle: String {
        NSLocalizedString(
            "best_stories_title",
            tableName: "LiveHackrNews",
            bundle: Bundle(for: LiveHackrNewsPresenter.self),
            value: "",
            comment: "Best Stories title view"
        )
    }

    private var errorMessage: String {
        NSLocalizedString(
            "new_stories_error_message",
            tableName: "LiveHackrNews",
            bundle: Bundle(for: LiveHackrNewsPresenter.self),
            value: "",
            comment: "New Stories loading error message"
        )
    }

    public init(view: LiveHackrNewsView, loadingView: LiveHackrNewsLoadingView, errorView: LiveHackrNewsErrorView) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoadingNews() {
        loadingView.display(LiveHackrNewsLoadingViewModel(isLoading: true))
        errorView.display(.noErrorMessage)
    }

    public func didFinishLoadingNews(news: [HackrNew]) {
        loadingView.display(LiveHackrNewsLoadingViewModel(isLoading: false))
        view.display(LiveHackrNewsViewModel(stories: news))
    }

    public func didFinishLoadingNews(with _: Error) {
        loadingView.display(LiveHackrNewsLoadingViewModel(isLoading: false))
        errorView.display(LiveHackrNewsErrorViewModel(message: errorMessage))
    }
}
