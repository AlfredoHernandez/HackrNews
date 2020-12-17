//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

struct LiveHackrNewsLoadingViewModel {
    let isLoading: Bool
}

protocol LiveHackrNewsLoadingView {
    func display(_ viewModel: LiveHackrNewsLoadingViewModel)
}

struct LiveHackrNewsViewModel {
    let news: [LiveHackrNew]
}

protocol LiveHackrNewsView {
    func display(_ viewModel: LiveHackrNewsViewModel)
}

final class LiveHackrNewsPresenter {
    typealias Observer<T> = (T) -> Void
    private let loader: LiveHackrNewsLoader

    init(loader: LiveHackrNewsLoader) {
        self.loader = loader
    }

    var liveHackrNewsView: LiveHackrNewsView?
    var loadingView: LiveHackrNewsLoadingView?

    func loadNews() {
        loadingView?.display(LiveHackrNewsLoadingViewModel(isLoading: true))
        loader.load { [weak self] result in
            if let news = try? result.get() {
                self?.liveHackrNewsView?.display(LiveHackrNewsViewModel(news: news))
            }
            self?.loadingView?.display(LiveHackrNewsLoadingViewModel(isLoading: false))
        }
    }
}
