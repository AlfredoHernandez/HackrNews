//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import HackrNews
import HackrNewsiOS

class StoryDetailsUIComposer {
    public static func composeWith(
        model: StoryDetail,
        didSelectStory: @escaping () -> Void,
        loader: @escaping (Int) -> AnyPublisher<StoryComment, Error>
    ) -> StoryDetailsViewController {
        let storyCellController = StoryCellController(viewModel: StoryDetailsPresenter.map(model), didSelect: didSelectStory)
        var bodyTextController: StoryBodyCellController?
        if let body = model.text { bodyTextController = StoryBodyCellController(body: body) }
        let controller = StoryDetailsViewController(
            storyCellController: storyCellController,
            bodyCommentCellController: bodyTextController
        )
        controller.title = model.title
        controller.display(model.comments?.map { [loader] comment in
            let adapter = LoadResourcePresentationAdapter<StoryComment, StoryDeailsViewAdapter>(loader: { loader(comment) })
            let controller = CommentCellController(delegate: adapter)
            adapter.presenter = LoadResourcePresenter(
                resourceView: StoryDeailsViewAdapter(controller: controller),
                loadingView: WeakRefVirtualProxy(controller),
                errorView: WeakRefVirtualProxy(controller),
                mapper: { CommentPresenter.map($0) }
            )
            return controller
        } ?? [])
        return controller
    }
}

extension LoadResourcePresentationAdapter: CommentCellControllerDelegate {
    func didRequestComment() {
        didRequestResource()
    }
}
