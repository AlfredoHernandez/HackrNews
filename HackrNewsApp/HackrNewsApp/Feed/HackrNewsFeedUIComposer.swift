//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import UIKit

final class HackrNewsFeedUIComposer {
    private init() {}

    static func composeWith(
        contentType: ContentType,
        hackrNewsFeedloader: HackrNewsFeedLoader,
        hackrStoryLoader: @escaping (Int) -> HackrStoryLoader,
        didSelectStory: @escaping (Story) -> Void,
        locale: Locale = .current,
        calendar: Calendar = Calendar(identifier: .gregorian)
    ) -> HackrNewsFeedViewController {
        let presentationAdapter = HackrNewsFeedPresentationAdapter(loader: MainQueueDispatchDecorator(hackrNewsFeedloader))
        let refreshController = HackrNewsFeedRefreshController(delegate: presentationAdapter)
        let viewController = makeViewController(with: refreshController, contentType: contentType)
        presentationAdapter.presenter = HackrNewsFeedPresenter(
            view: StoryViewAdapter(
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
        with refreshController: HackrNewsFeedRefreshController,
        contentType: ContentType
    ) -> HackrNewsFeedViewController {
        let viewController = HackrNewsFeedViewController(refreshController: refreshController)
        let config = tabBarControllerConfig(for: contentType)
        viewController.title = config.title
        viewController.tabBarItem.image = config.image
        viewController.tabBarItem.selectedImage = config.selected
        return viewController
    }

    private static func tabBarControllerConfig(for contentType: ContentType) -> (title: String, image: UIImage, selected: UIImage) {
        switch contentType {
        case .topStories:
            return (HackrNewsFeedPresenter.topStoriesTitle, Icons.top.image(state: .normal), Icons.top.image(state: .selected))
        case .newStories:
            return (HackrNewsFeedPresenter.newStoriesTitle, Icons.new.image(state: .normal), Icons.new.image(state: .selected))
        case .bestStories:
            return (HackrNewsFeedPresenter.bestStoriesTitle, Icons.best.image(state: .normal), Icons.best.image(state: .selected))
        }
    }
}
