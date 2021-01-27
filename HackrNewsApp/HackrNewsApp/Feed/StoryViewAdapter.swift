//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews
import HackrNewsiOS

final class StoryViewAdapter: HackrNewsFeedView {
    private let loader: (Int) -> HackrStoryLoader
    private let locale: Locale
    private let calendar: Calendar
    private let didSelectStory: (Story) -> Void
    private weak var controller: HackrNewsFeedViewController?

    init(
        loader: @escaping (Int) -> HackrStoryLoader,
        controller: HackrNewsFeedViewController,
        didSelectStory: @escaping (Story) -> Void,
        locale: Locale,
        calendar: Calendar
    ) {
        self.loader = loader
        self.controller = controller
        self.didSelectStory = didSelectStory
        self.locale = locale
        self.calendar = calendar
    }

    func display(_ viewModel: HackrNewsFeedViewModel) {
        controller?.display(viewModel.stories.map { new in
            var story: Story?
            let adapter = StoryPresentationAdapter(
                model: new,
                loader: MainQueueDispatchDecorator(loader(new.id)),
                completion: { storyResult in
                    story = storyResult
                }
            )
            let controller = HackrNewFeedCellController(delegate: adapter, didSelectStory: { [weak self] in
                guard let story = story else { return }
                self?.didSelectStory(story)
            })
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
