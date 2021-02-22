//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol HackrNewFeedCellControllerDelegate {
    func didRequestStory()
    func didCancelRequest()
}

public final class HackrNewFeedCellController: NSObject, StoryView, StoryLoadingView, StoryErrorView {
    private let delegate: HackrNewFeedCellControllerDelegate
    private let didSelectStory: () -> Void
    private var cell: HackrNewFeedCell?
    private var viewModel: StoryViewModel?
    private var tableView: UITableView?

    public init(delegate: HackrNewFeedCellControllerDelegate, didSelectStory: @escaping () -> Void) {
        self.delegate = delegate
        self.didSelectStory = didSelectStory
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        self.tableView = tableView
        cell?.retryLoadStoryButton.addTarget(self, action: #selector(loadComment), for: .touchUpInside)

        // The model already exists in cache, how could I check from local loader?
        if let viewModel = viewModel {
            updateCell(with: viewModel)
        } else {
            loadComment()
        }
        return cell!
    }

    func preload() {
        // How could I validate if exists in cache?
        guard viewModel == nil else { return }
        delegate.didRequestStory()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelRequest()
    }

    public func display(_ viewModel: StoryLoadingViewModel) {
        cell?.isLoadingContent = viewModel.isLoading
    }

    public func display(_ viewModel: StoryViewModel) {
        self.viewModel = viewModel
        tableView?.beginUpdates()
        updateCell(with: viewModel)
        tableView?.endUpdates()
    }

    private func updateCell(with viewModel: StoryViewModel) {
        cell?.titleLabel.text = viewModel.title
        cell?.urlLabel.text = viewModel.displayURL
        cell?.authorLabel.text = viewModel.author
        cell?.commentsLabel.text = viewModel.comments
        cell?.scoreLabel.text = viewModel.score
        cell?.createdAtLabel.text = viewModel.date
    }

    public func display(_ viewModel: StoryErrorViewModel) {
        cell?.errorContentView.isHidden = viewModel.error == nil
    }

    func didSelect() {
        didSelectStory()
    }

    @objc private func loadComment() {
        delegate.didRequestStory()
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
