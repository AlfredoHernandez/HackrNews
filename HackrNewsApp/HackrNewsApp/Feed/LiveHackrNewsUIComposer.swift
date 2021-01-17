//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews
import HackrNewsiOS

final class LiveHackrNewsUIComposer {
    private init() {}

    static func composeWith(
        contentType: ContentType,
        liveHackrNewsloader: LiveHackrNewsLoader,
        hackrStoryLoader: @escaping (Int) -> HackrStoryLoader,
        didSelectStory: @escaping (URL) -> Void,
        locale: Locale = .current,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> LiveHackrNewsViewController {
        let presentationAdapter = LiveHackrNewsPresentationAdapter(liveHackrNewsloader: MainQueueDispatchDecorator(liveHackrNewsloader))
        let refreshController = LiveHackrNewsRefreshController(delegate: presentationAdapter)
        let viewController = makeViewController(with: refreshController, contentType: contentType)
        presentationAdapter.presenter = LiveHackrNewsPresenter(
            view: LiveHackrNewsViewAdapter(
                loader: hackrStoryLoader,
                controller: viewController,
                didSelectStory: didSelectStory,
                locale: locale,
                calendar: calendar
            ),
            loadingView: WeakRefVirtualProxy(refreshController),
            errorView: WeakRefVirtualProxy(viewController)
        )
        return viewController
    }

    private static func makeViewController(
        with refreshController: LiveHackrNewsRefreshController,
        contentType: ContentType
    ) -> LiveHackrNewsViewController {
        let viewController = LiveHackrNewsViewController(refreshController: refreshController)
        switch contentType {
        case .topStories:
            viewController.tabBarItem.image = Icons.top.image(state: .normal)
            viewController.tabBarItem.selectedImage = Icons.top.image(state: .selected)
            viewController.title = LiveHackrNewsPresenter.topStoriesTitle
        case .newStories:
            viewController.tabBarItem.image = Icons.new.image(state: .normal)
            viewController.tabBarItem.selectedImage = Icons.new.image(state: .selected)
            viewController.title = LiveHackrNewsPresenter.newStoriesTitle
        case .bestStories:
            viewController.tabBarItem.image = Icons.best.image(state: .normal)
            viewController.tabBarItem.selectedImage = Icons.best.image(state: .selected)
            viewController.title = LiveHackrNewsPresenter.bestStoriesTitle
        }
        return viewController
    }
}
