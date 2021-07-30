//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import HackrNews
import HackrNewsiOS

final class StoryViewAdapter: ResourceView {
    private let loader: (Int) -> AnyPublisher<Story, Error>
    private let didSelectStory: (Story) -> Void
    private weak var controller: HackrNewsFeedViewController?
    private var stories: [Int: Story] = [:]
    private let locale: Locale
    private let calendar: Calendar

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
        let locale = self.locale
        let calendar = self.calendar
        controller?.display(viewModel.stories.map { new in
            let adapter = LoadResourcePresentationAdapter<Story, WeakRefVirtualProxy<HackrNewFeedCellController>>(loader: { [loader] in
                loader(new.id).handleEvents(receiveOutput: { [weak self] story in
                    self?.stories[story.id] = story
                }).eraseToAnyPublisher()
            })
            let controller = HackrNewFeedCellController(delegate: adapter, didSelectStory: { [weak self] in
                guard let story = self?.stories[new.id] else { return }
                self?.didSelectStory(story)
            })
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(controller),
                loadingView: WeakRefVirtualProxy(controller),
                errorView: WeakRefVirtualProxy(controller),
                mapper: { StoryPresenter.map(story: $0, locale: locale, calendar: calendar) }
            )
            return controller
        })
    }
}

extension LoadResourcePresentationAdapter: HackrNewFeedCellControllerDelegate {
    func didRequestStory() {
        didRequestResource()
    }

    func didCancelRequestStory() {
        didCancelRequest()
    }
}
