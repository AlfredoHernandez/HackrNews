//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

public class StoryDetailsUIComposer {
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

class CommentPresentationAdapter: CommentCellControllerDelegate {
    let loader: CommentLoader
    var presenter: CommentPresenter?

    init(loader: CommentLoader) {
        self.loader = loader
    }

    func didRequestComment() {
        presenter?.didStartLoadingComment()
        loader.load { [weak self] result in
            switch result {
            case let .success(comment):
                self?.presenter?.didFinishLoadingComment(with: comment)
            case let .failure(error):
                self?.presenter?.didFinishLoadingComment(with: error)
            }
        }
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: CommentView where T: CommentView {
    func display(_ viewModel: CommentViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CommentLoadingView where T: CommentLoadingView {
    func display(_ viewModel: CommentLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CommentErrorView where T: CommentErrorView {
    func display(_ viewModel: CommentErrorViewModel) {
        object?.display(viewModel)
    }
}

final class MainQueueDispatchDecorator<T> {
    let decoratee: T

    init(_ decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: CommentLoader where T == CommentLoader {
    func load(completion: @escaping (CommentLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

// MARK: - Comment Loader

extension RemoteLoader: CommentLoader where Resource == StoryComment {
    public func load(completion: @escaping (Result) -> Void) {
        let _: HTTPClientTask = load(completion: completion)
    }
}
