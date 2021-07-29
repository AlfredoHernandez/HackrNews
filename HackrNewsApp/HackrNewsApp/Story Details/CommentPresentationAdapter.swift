//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import HackrNews
import HackrNewsiOS

class CommentPresentationAdapter: CommentCellControllerDelegate {
    let loader: () -> AnyPublisher<StoryComment, Error>
    var presenter: CommentPresenter?
    var task: Cancellable?
    private var isLoading = false

    init(loader: @escaping () -> AnyPublisher<StoryComment, Error>) {
        self.loader = loader
    }

    func didRequestComment() {
        guard !isLoading else { return }
        presenter?.didStartLoadingComment()
        isLoading = true
        task = loader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case let .failure(error):
                    self?.presenter?.didFinishLoadingComment(with: error)
                }
                self?.isLoading = false
            }, receiveValue: { [weak self] comment in
                self?.presenter?.didFinishLoadingComment(with: comment)
            })
    }

    func didCancelRequest() {
        task?.cancel()
        isLoading = false
    }
}
