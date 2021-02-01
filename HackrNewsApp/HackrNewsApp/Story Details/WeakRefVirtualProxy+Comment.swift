//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

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
