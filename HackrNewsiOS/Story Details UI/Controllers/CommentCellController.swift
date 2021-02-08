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

public class CommentCellController: CommentView, CommentLoadingView, CommentErrorView {
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
        // simulate cache
        if let viewModel = viewModel {
            cell?.isLoadingContent = false
            // update without animation when using cached data
            updateCell(with: viewModel)
        } else {
            delegate.didRequestComment()
        }
        return cell!
    }

    func preload() {
        // simulate cache -
        // shouldn't preload if data is available
        guard viewModel == nil else { return }
        delegate.didRequestComment()
    }

    func cancel() {
        releaseCellForReuse()
        delegate.didCancelRequest()
    }

    public func display(_ viewModel: CommentViewModel) {
        self.viewModel = viewModel
        // update animated when new data comes
        // to recalculate cell height
        tableView?.beginUpdates()
        updateCell(with: viewModel)
        tableView?.endUpdates()
    }

    private func updateCell(with viewModel: CommentViewModel) {
        cell?.authorLabel.text = viewModel.author
        cell?.createdAtLabel.text = viewModel.createdAt
        cell?.bodyLabel.text = parse(content: viewModel.text)
    }

    public func display(_ viewModel: CommentLoadingViewModel) {
        cell?.isLoadingContent = viewModel.isLoading
    }

    public func display(_: CommentErrorViewModel) {}

    private func releaseCellForReuse() {
        cell = nil
        tableView = nil
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
