//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews
import HackrNewsiOS

final class HackrNewsFeedPresentationAdapter: HackrNewsFeedRefreshControllerDelegate {
    private let loader: HackrNewsFeedLoader
    var presenter: LiveHackrNewsPresenter?

    init(loader: HackrNewsFeedLoader) {
        self.loader = loader
    }

    func didRequestNews() {
        presenter?.didStartLoadingNews()
        loader.load { [weak self] result in
            switch result {
            case let .success(news):
                self?.presenter?.didFinishLoadingNews(news: news)
            case let .failure(error):
                self?.presenter?.didFinishLoadingNews(with: error)
            }
        }
    }
}
