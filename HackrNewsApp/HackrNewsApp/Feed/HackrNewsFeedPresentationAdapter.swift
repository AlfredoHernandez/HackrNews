//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews
import HackrNewsiOS

final class HackrNewsFeedPresentationAdapter: HackrNewsFeedRefreshControllerDelegate {
    private let loader: HackrNewsFeedLoader
    var presenter: HackrNewsFeedPresenter?
    private var isLoading = false

    init(loader: HackrNewsFeedLoader) {
        self.loader = loader
    }

    func didRequestNews() {
        guard !isLoading else { return }
        presenter?.didStartLoadingNews()
        isLoading = true
        loader.load { [weak self] result in
            switch result {
            case let .success(news):
                self?.presenter?.didFinishLoadingNews(news: news)
            case let .failure(error):
                self?.presenter?.didFinishLoadingNews(with: error)
            }
            self?.isLoading = false
        }
    }
}
