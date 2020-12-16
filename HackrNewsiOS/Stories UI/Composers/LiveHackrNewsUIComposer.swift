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
        let viewModel = LiveHackrNewsViewModel(loader: liveHackrNewsloader)
        let refreshController = LiveHackrNewsRefreshController(viewModel: viewModel)
        let viewController = LiveHackrNewsViewController(refreshController: refreshController)
        viewModel.onLoad = adaptLiveHackrNewsToCellControllers(forwardingTo: viewController, loader: hackrStoryLoader)
        return viewController
    }

    private static func adaptLiveHackrNewsToCellControllers(
        forwardingTo controller: LiveHackrNewsViewController,
        loader: HackrStoryLoader
    ) -> (([LiveHackrNew]) -> Void) {
        return { [weak controller] stories in
            controller?.tableModel = stories.map { model in
                LiveHackrNewCellController(viewModel: LiveHackrNewViewModel(model: model, loader: loader))
            }
        }
    }
}
