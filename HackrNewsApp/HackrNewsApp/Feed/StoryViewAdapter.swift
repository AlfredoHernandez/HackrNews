//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import HackrNews
import HackrNewsiOS

final class StoryViewAdapter: HackrNewsFeedView {
    private let loader: (Int) -> AnyPublisher<Story, Error>
    private let locale: Locale
    private let calendar: Calendar
    private let didSelectStory: (Story) -> Void
    private weak var controller: HackrNewsFeedViewController?

    init(
        loader: @escaping (Int) -> AnyPublisher<Story, Error>,
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
            let adapter = StoryPresentationAdapter(
                model: new,
                loader: { [loader] in loader(new.id) }
            )
            let controller = HackrNewFeedCellController(delegate: adapter, didSelectStory: { [weak self] in
                guard let story = adapter.storyResult?() else { return }
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
