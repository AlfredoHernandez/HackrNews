//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import UIKit

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
        let config = tabBarControllerConfig(for: contentType)
        viewController.title = config.title
        viewController.tabBarItem.image = config.image
        viewController.tabBarItem.selectedImage = config.selected
        return viewController
    }

    private static func tabBarControllerConfig(for contentType: ContentType) -> (title: String, image: UIImage, selected: UIImage) {
        switch contentType {
        case .topStories:
            return (LiveHackrNewsPresenter.topStoriesTitle, Icons.top.image(state: .normal), Icons.top.image(state: .selected))
        case .newStories:
            return (LiveHackrNewsPresenter.newStoriesTitle, Icons.new.image(state: .normal), Icons.new.image(state: .selected))
        case .bestStories:
            return (LiveHackrNewsPresenter.bestStoriesTitle, Icons.best.image(state: .normal), Icons.best.image(state: .selected))
        }
    }
}
