//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol CommentCellControllerDelegate {
    func didRequestComment()
}

public class CommentCellController: CommentView, CommentLoadingView, CommentErrorView {
    private(set) var cell: CommentCell?
    private let delegate: CommentCellControllerDelegate

    public init(delegate: CommentCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> CommentCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestComment()
        return cell!
    }

    func preload() {
        delegate.didRequestComment()
    }

    public func display(_ viewModel: CommentViewModel) {
        cell?.authorLabel.text = viewModel.author
        cell?.createdAtLabel.text = viewModel.createdAt
        cell?.bodyLabel.text = viewModel.text
    }

    public func display(_ viewModel: CommentLoadingViewModel) {
        cell?.isLoadingContent = viewModel.isLoading
    }

    public func display(_: CommentErrorViewModel) {}
}
