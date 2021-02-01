//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS

class StoryDetailsUIComposer {
    public static func composeWith(model: StoryDetail, loader: (Int) -> CommentLoader) -> StoryDetailsViewController {
        let storyCellController = StoryCellController(viewModel: StoryDetailsPresenter.map(model))
        let controller = StoryDetailsViewController(storyCellController: storyCellController)
        controller.title = StoryDetailsPresenter.title
        controller.display(model.comments?.map { [loader] comment in
            let adapter = CommentPresentationAdapter(loader: MainQueueDispatchDecorator(loader(comment)))
            let controller = CommentCellController(delegate: adapter)
            adapter.presenter = CommentPresenter(
                view: WeakRefVirtualProxy(controller),
                loadingView: WeakRefVirtualProxy(controller),
                errorView: WeakRefVirtualProxy(controller)
            )
            return controller
        } ?? [])
        return controller
    }
}

// MARK: - Comment Loader

extension RemoteLoader: CommentLoader where Resource == StoryComment {
    public func load(completion: @escaping (Result) -> Void) {
        let _: HTTPClientTask = load(completion: completion)
    }
}
