//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

public final class LiveHackrNewsUIComposer {
    private init() {}

    public static func composeWith(
        liveHackrNewsloader: LiveHackrNewsLoader,
        hackrStoryLoader: HackrStoryLoader
    ) -> LiveHackrNewsViewController {
        let liveHackrNewsPresenter = LiveHackrNewsPresenter()
        let presentationAdapter = LiveHackrNewsPresentationAdapter(
            liveHackrNewsloader: liveHackrNewsloader,
            presenter: liveHackrNewsPresenter
        )
        let refreshController = LiveHackrNewsRefreshController(delegate: presentationAdapter)
        let viewController = LiveHackrNewsViewController(refreshController: refreshController)
        liveHackrNewsPresenter.loadingView = WeakRefVirtualProxy(refreshController)
        liveHackrNewsPresenter.liveHackrNewsView = LiveHackrNewsViewAdapter(loader: hackrStoryLoader, controller: viewController)
        return viewController
    }

    private static func adaptLiveHackrNewsToCellControllers(
        forwardingTo controller: LiveHackrNewsViewController,
        loader: HackrStoryLoader
    ) -> (([LiveHackrNew]) -> Void) {
        return { [weak controller] stories in
            controller?.tableModel = stories.map { model in
                LiveHackrNewCellController(viewModel: StoryViewModel(model: model, loader: loader))
            }
        }
    }
}

private final class LiveHackrNewsViewAdapter: LiveHackrNewsView {
    private let loader: HackrStoryLoader
    private weak var controller: LiveHackrNewsViewController?

    init(loader: HackrStoryLoader, controller: LiveHackrNewsViewController) {
        self.loader = loader
        self.controller = controller
    }

    func display(_ viewModel: LiveHackrNewsViewModel) {
        controller?.tableModel = viewModel.news.map { new in
            LiveHackrNewCellController(viewModel: StoryViewModel(model: new, loader: loader))
        }
    }
}

private final class LiveHackrNewsPresentationAdapter: LiveHackrNewsRefreshControllerDelegate {
    private let liveHackrNewsloader: LiveHackrNewsLoader
    private let presenter: LiveHackrNewsPresenter

    init(liveHackrNewsloader: LiveHackrNewsLoader, presenter: LiveHackrNewsPresenter) {
        self.liveHackrNewsloader = liveHackrNewsloader
        self.presenter = presenter
    }

    func didRequestNews() {
        presenter.didStartLoadingNews()
        liveHackrNewsloader.load { [weak self] result in
            switch result {
            case let .success(news):
                self?.presenter.didFinishLoadingNews(news: news)
            case let .failure(error):
                self?.presenter.didFinishLoadingNews(with: error)
            }
        }
    }
}
