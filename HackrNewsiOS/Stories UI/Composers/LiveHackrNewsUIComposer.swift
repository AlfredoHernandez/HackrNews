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
        let presentationAdapter = LiveHackrNewsPresentationAdapter(liveHackrNewsloader: liveHackrNewsloader)
        let refreshController = LiveHackrNewsRefreshController(delegate: presentationAdapter)
        let viewController = LiveHackrNewsViewController(refreshController: refreshController)
        presentationAdapter.presenter = LiveHackrNewsPresenter(
            view: LiveHackrNewsViewAdapter(loader: hackrStoryLoader, controller: viewController),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: WeakRefVirtualProxy(viewController)
        )
        return viewController
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
        controller?.tableModel = viewModel.stories.map { new in
            LiveHackrNewCellController(viewModel: StoryViewModel(model: new, loader: loader))
        }
    }
}

private final class LiveHackrNewsPresentationAdapter: LiveHackrNewsRefreshControllerDelegate {
    private let liveHackrNewsloader: LiveHackrNewsLoader
    var presenter: LiveHackrNewsPresenter?

    init(liveHackrNewsloader: LiveHackrNewsLoader) {
        self.liveHackrNewsloader = liveHackrNewsloader
    }

    func didRequestNews() {
        presenter?.didStartLoadingNews()
        liveHackrNewsloader.load { [weak self] result in
            switch result {
            case let .success(news):
                self?.presenter?.didFinishLoadingNews(news: news)
            case let .failure(error):
                self?.presenter?.didFinishLoadingNews(with: error)
            }
        }
    }
}
