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
        refreshController.onLoad = { [weak viewController] stories in
            viewController?.tableModel = stories.map { model in
                LiveHackrNewCellController(model: model, loader: hackrStoryLoader)
            }
        }
        return viewController
    }
}
