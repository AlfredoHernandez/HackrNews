//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews
import HackrNewsiOS

final class LiveHackrNewsViewAdapter: LiveHackrNewsView {
    private let loader: (Int) -> HackrStoryLoader
    private let locale: Locale
    private let calendar: Calendar
    private let didSelectStory: (URL) -> Void
    private weak var controller: LiveHackrNewsViewController?

    init(
        loader: @escaping (Int) -> HackrStoryLoader,
        controller: LiveHackrNewsViewController,
        didSelectStory: @escaping (URL) -> Void,
        locale: Locale,
        calendar: Calendar
    ) {
        self.loader = loader
        self.controller = controller
        self.didSelectStory = didSelectStory
        self.locale = locale
        self.calendar = calendar
    }

    func display(_ viewModel: LiveHackrNewsViewModel) {
        controller?.display(viewModel.stories.map { new in
            let adapter = LiveHackrNewPresentationAdapter(model: new, loader: MainQueueDispatchDecorator(loader(new.id)))
            let controller = LiveHackrNewCellController(delegate: adapter, didSelectStory: didSelectStory)
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