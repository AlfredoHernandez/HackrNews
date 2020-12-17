//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

protocol LiveHackrNewsLoadingView {
    func display(isLoading: Bool)
}

protocol LiveHackrNewsView {
    func display(news: [LiveHackrNew])
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
        loadingView?.display(isLoading: true)
        loader.load { [weak self] result in
            if let news = try? result.get() {
                self?.liveHackrNewsView?.display(news: news)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
