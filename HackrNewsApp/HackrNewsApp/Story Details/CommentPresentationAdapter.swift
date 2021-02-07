//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS

class CommentPresentationAdapter: CommentCellControllerDelegate {
    let loader: CommentLoader
    var presenter: CommentPresenter?
    var task: CommentLoaderTask?
    private var isLoading = false

    init(loader: CommentLoader) {
        self.loader = loader
    }

    func didRequestComment() {
        guard !isLoading else { return }
        presenter?.didStartLoadingComment()
        isLoading = true
        task = loader.load { [weak self] result in
            switch result {
            case let .success(comment):
                self?.presenter?.didFinishLoadingComment(with: comment)
            case let .failure(error):
                self?.presenter?.didFinishLoadingComment(with: error)
            }
            self?.isLoading = false
        }
    }

    func didCancelRequest() {
        task?.cancel()
        isLoading = false
    }
}
