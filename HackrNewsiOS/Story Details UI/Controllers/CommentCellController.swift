//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol CommentCellControllerDelegate {
    func didRequestComment()
    func didCancelRequest()
}

public class CommentCellController: CommentView, CommentLoadingView, CommentErrorView {
    private(set) var cell: CommentCell?
    private let delegate: CommentCellControllerDelegate
    private var viewModel: CommentViewModel?

    public init(delegate: CommentCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> CommentCell {
        cell = tableView.dequeueReusableCell()
        if viewModel == nil {
            delegate.didRequestComment()
        } else {
            cell?.isLoadingContent = false
            display(viewModel!)
        }
        return cell!
    }

    func preload() {
        delegate.didRequestComment()
    }

    func cancel() {
        releaseCellForReuse()
        delegate.didCancelRequest()
    }

    public func display(_ viewModel: CommentViewModel) {
        self.viewModel = viewModel
        cell?.authorLabel.text = viewModel.author
        cell?.createdAtLabel.text = viewModel.createdAt
        cell?.bodyLabel.text = viewModel.text
    }

    public func display(_ viewModel: CommentLoadingViewModel) {
        cell?.isLoadingContent = viewModel.isLoading
    }

    public func display(_: CommentErrorViewModel) {}
    
    private func releaseCellForReuse() {
        cell = nil
    }
}
