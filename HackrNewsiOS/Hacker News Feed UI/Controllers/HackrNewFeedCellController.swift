//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
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
    public typealias ResourceViewModel = StoryViewModel
    private var tableView: UITableView?

    public init(delegate: HackrNewFeedCellControllerDelegate, didSelectStory: @escaping () -> Void) {
        self.delegate = delegate
        self.didSelectStory = didSelectStory
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        self.tableView = tableView
        cell = tableView.dequeueReusableCell()
        cell?.retryLoadStoryButton.addTarget(self, action: #selector(loadComment), for: .touchUpInside)
        loadComment()
        return cell!
    }

    func preload() {
        delegate.didRequestStory()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelRequestStory()
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell?.isLoadingContent = viewModel.isLoading
    }

    public func display(_ viewModel: StoryViewModel) {
        tableView?.beginUpdates()
        cell?.titleLabel.text = viewModel.title
        cell?.urlLabel.text = viewModel.displayURL
        cell?.authorLabel.text = viewModel.author
        cell?.commentsLabel.text = viewModel.comments
        cell?.scoreLabel.text = viewModel.score
        cell?.createdAtLabel.text = viewModel.date
        tableView?.endUpdates()
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
