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

    func cancel() {
        releaseCellForReuse()
        delegate.didCancelRequest()
    }

    public func display(_ viewModel: CommentViewModel) {
        print(viewModel)
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
