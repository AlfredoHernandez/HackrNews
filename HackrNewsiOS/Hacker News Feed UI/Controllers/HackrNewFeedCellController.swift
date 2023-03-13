//
//  Copyright © 2023 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol HackrNewFeedCellControllerDelegate {
    func didRequestStory()
    func didCancelRequestStory()
}

public final class HackrNewFeedCellController: NSObject, ResourceView, ResourceLoadingView, ResourceErrorView {
    private let delegate: HackrNewFeedCellControllerDelegate
    private let didSelectStory: () -> Void
    private var cell: HackrNewFeedCell?
    private var viewModel: StoryViewModel?
    private var tableView: UITableView?
    public typealias ResourceViewModel = StoryViewModel

    public init(delegate: HackrNewFeedCellControllerDelegate, didSelectStory: @escaping () -> Void) {
        self.delegate = delegate
        self.didSelectStory = didSelectStory
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        self.tableView = tableView

        if let viewModel = viewModel {
            cell?.isLoadingContent = false
            updateCell(with: viewModel)
        } else {
            loadComment()
        }

        cell?.retryLoadStoryButton.addTarget(self, action: #selector(loadComment), for: .touchUpInside)
        return cell!
    }

    func preload() {
        guard viewModel == nil else { return }
        delegate.didRequestStory()
    }

    func cancelLoad() {
        cell?.isLoadingContent = false
        releaseCellForReuse()
        delegate.didCancelRequestStory()
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
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

    public func display(_ viewModel: ResourceErrorViewModel) {
        cell?.errorContentView.isHidden = viewModel.message == nil
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
