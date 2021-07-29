//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import HackrNews
import HackrNewsiOS

final class HackrNewsFeedPresentationAdapter: HackrNewsFeedRefreshControllerDelegate {
    private let loader: () -> AnyPublisher<[HackrNew], Error>
    var presenter: HackrNewsFeedPresenter?
    private var isLoading = false
    private var cancellable: Cancellable?

    init(loader: @escaping () -> AnyPublisher<[HackrNew], Error>) {
        self.loader = loader
    }

    func didRequestNews() {
        guard !isLoading else { return }
        presenter?.didStartLoadingNews()
        isLoading = true
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingNews(with: error)
                }
                self?.isLoading = false
            } receiveValue: { [weak self] news in
                self?.presenter?.didFinishLoadingNews(news: news)
            }
    }
}
