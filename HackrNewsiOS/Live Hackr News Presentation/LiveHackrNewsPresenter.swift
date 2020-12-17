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
    private let liveHackrNewsView: LiveHackrNewsView
    private let loadingView: LiveHackrNewsLoadingView

    init(liveHackrNewsView: LiveHackrNewsView, loadingView: LiveHackrNewsLoadingView) {
        self.liveHackrNewsView = liveHackrNewsView
        self.loadingView = loadingView
    }

    func didStartLoadingNews() {
        loadingView.display(LiveHackrNewsLoadingViewModel(isLoading: true))
    }

    func didFinishLoadingNews(news: [LiveHackrNew]) {
        liveHackrNewsView.display(LiveHackrNewsViewModel(news: news))
        loadingView.display(LiveHackrNewsLoadingViewModel(isLoading: false))
    }

    func didFinishLoadingNews(with _: Error) {
        loadingView.display(LiveHackrNewsLoadingViewModel(isLoading: false))
    }
}
