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
        let refreshController = LiveHackrNewsRefreshController(loader: liveHackrNewsloader)
        let viewController = LiveHackrNewsViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptLiveHackrNewsToCellControllers(forwardingTo: viewController, loader: hackrStoryLoader)
        return viewController
    }

    private static func adaptLiveHackrNewsToCellControllers(
        forwardingTo controller: LiveHackrNewsViewController,
        loader: HackrStoryLoader
    ) -> (([LiveHackrNew]) -> Void) {
        return { [weak controller] stories in
            controller?.tableModel = stories.map { model in
                LiveHackrNewCellController(model: model, loader: loader)
            }
        }
    }
}
