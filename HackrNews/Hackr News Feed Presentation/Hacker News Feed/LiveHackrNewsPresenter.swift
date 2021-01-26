//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class LiveHackrNewsPresenter {
    private let view: HackrNewsFeedView
    private let loadingView: HackrNewsFeedLoadingView
    private let errorView: HackrNewsFeedErrorView

    public static var topStoriesTitle: String {
        NSLocalizedString(
            "top_stories_title",
            tableName: "HackrNewsFeed",
            bundle: Bundle(for: LiveHackrNewsPresenter.self),
            value: "",
            comment: "Top Stories title view"
        )
    }

    public static var newStoriesTitle: String {
        NSLocalizedString(
            "new_stories_title",
            tableName: "HackrNewsFeed",
            bundle: Bundle(for: LiveHackrNewsPresenter.self),
            value: "",
            comment: "New Stories title view"
        )
    }

    public static var bestStoriesTitle: String {
        NSLocalizedString(
            "best_stories_title",
            tableName: "HackrNewsFeed",
            bundle: Bundle(for: LiveHackrNewsPresenter.self),
            value: "",
            comment: "Best Stories title view"
        )
    }

    private var errorMessage: String {
        NSLocalizedString(
            "new_stories_error_message",
            tableName: "HackrNewsFeed",
            bundle: Bundle(for: LiveHackrNewsPresenter.self),
            value: "",
            comment: "New Stories loading error message"
        )
    }

    public init(view: HackrNewsFeedView, loadingView: HackrNewsFeedLoadingView, errorView: HackrNewsFeedErrorView) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoadingNews() {
        loadingView.display(HackrNewsFeedLoadingViewModel(isLoading: true))
        errorView.display(.noErrorMessage)
    }

    public func didFinishLoadingNews(news: [HackrNew]) {
        loadingView.display(HackrNewsFeedLoadingViewModel(isLoading: false))
        view.display(HackrNewsFeedViewModel(stories: news))
    }

    public func didFinishLoadingNews(with _: Error) {
        loadingView.display(HackrNewsFeedLoadingViewModel(isLoading: false))
        errorView.display(HackrNewsFeedErrorViewModel(message: errorMessage))
    }
}
