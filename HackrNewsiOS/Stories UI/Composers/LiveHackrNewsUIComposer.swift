//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

public final class LiveHackrNewsUIComposer {
    private init() {}

    public static func composeWith(
        liveHackrNewsloader: LiveHackrNewsLoader,
        hackrStoryLoader: HackrStoryLoader,
        locale: Locale = .current,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> LiveHackrNewsViewController {
        let presentationAdapter = LiveHackrNewsPresentationAdapter(liveHackrNewsloader: MainQueueDispatchDecorator(liveHackrNewsloader))
        let refreshController = LiveHackrNewsRefreshController(delegate: presentationAdapter)
        let viewController = LiveHackrNewsViewController(refreshController: refreshController)
        presentationAdapter.presenter = LiveHackrNewsPresenter(
            view: LiveHackrNewsViewAdapter(
                loader: MainQueueDispatchDecorator(hackrStoryLoader),
                controller: viewController,
                locale: locale,
                calendar: calendar
            ),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: WeakRefVirtualProxy(viewController)
        )
        return viewController
    }
}

private final class LiveHackrNewsViewAdapter: LiveHackrNewsView {
    private let loader: HackrStoryLoader
    private let locale: Locale
    private let calendar: Calendar
    private weak var controller: LiveHackrNewsViewController?

    init(loader: HackrStoryLoader, controller: LiveHackrNewsViewController, locale: Locale, calendar: Calendar) {
        self.loader = loader
        self.controller = controller
        self.locale = locale
        self.calendar = calendar
    }

    func display(_ viewModel: LiveHackrNewsViewModel) {
        controller?.display(viewModel.stories.map { new in
            let adapter = LiveHackrNewPresentationAdapter(model: new, loader: loader)
            let controller = LiveHackrNewCellController(delegate: adapter)
            adapter.presenter = StoryPresenter(
                view: WeakRefVirtualProxy(controller),
                loadingView: WeakRefVirtualProxy(controller),
                errorView: WeakRefVirtualProxy(controller),
                locale: locale,
                calendar: calendar
            )
            return controller
        })
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

private final class LiveHackrNewPresentationAdapter: LiveHackrNewCellControllerDelegate {
    private let model: LiveHackrNew
    private let loader: HackrStoryLoader
    private var task: HackrStoryLoaderTask?

    var presenter: StoryPresenter?

    init(model: LiveHackrNew, loader: HackrStoryLoader) {
        self.model = model
        self.loader = loader
    }

    func didRequestStory() {
        presenter?.didStartLoadingStory(from: model)
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(model.id).json")!
        task = loader.load(from: url) { [weak self] result in
            switch result {
            case let .success(story):
                self?.presenter?.didFinishLoadingStory(story: story)
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }

    func didCancelRequest() {
        task?.cancel()
    }
}
