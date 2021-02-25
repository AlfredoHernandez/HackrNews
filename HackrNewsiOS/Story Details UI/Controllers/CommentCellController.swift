//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import SwiftSoup
import UIKit

public protocol CommentCellControllerDelegate {
    func didRequestComment()
    func didCancelRequest()
}

public class CommentCellController: NSObject, CommentView, CommentLoadingView, CommentErrorView {
    private(set) var cell: CommentCell?
    private let delegate: CommentCellControllerDelegate
    private var viewModel: CommentViewModel?
    private var tableView: UITableView?

    public init(delegate: CommentCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> CommentCell {
        cell = tableView.dequeueReusableCell()
        self.tableView = tableView

        if let viewModel = viewModel {
            cell?.isLoadingContent = false
            updateCell(with: viewModel)
        } else {
            didStartCommentRequest()
        }

        cell?.retryButton.addTarget(self, action: #selector(didStartCommentRequest), for: .touchUpInside)
        return cell!
    }

    @objc private func didStartCommentRequest() {
        delegate.didRequestComment()
    }

    func preload() {
        guard viewModel == nil else { return }
        delegate.didRequestComment()
    }

    func cancel() {
        releaseCellForReuse()
        delegate.didCancelRequest()
    }

    public func display(_ viewModel: CommentViewModel) {
        self.viewModel = viewModel
        tableView?.beginUpdates()
        updateCell(with: viewModel)
        tableView?.endUpdates()
    }

    private func updateCell(with viewModel: CommentViewModel) {
        cell?.authorLabel.text = viewModel.author
        cell?.createdAtLabel.text = viewModel.createdAt
        if let text = viewModel.text {
            cell?.bodyLabel.text = parse(content: text)
        } else {
            cell?.bodyLabel.text = nil
        }
    }

    public func display(_ viewModel: CommentLoadingViewModel) {
        cell?.isLoadingContent = viewModel.isLoading
    }

    public func display(_ viewModel: CommentErrorViewModel) {
        cell?.errorContentView.isHidden = viewModel.error == nil
    }

    private func releaseCellForReuse() {
        cell = nil
    }

    private func parse(content: String) -> String {
        let paragraphIdentifier = "[P]"
        do {
            let html = try SwiftSoup.parse(content)
            _ = try html.select("p").before(paragraphIdentifier)
            let body = try html.text()
            return body.replacingOccurrences(of: "\(paragraphIdentifier) ", with: "\n\n")
        } catch {
            return content
        }
    }
}
