//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol HackrNewFeedCellControllerDelegate {
    func didRequestStory()
    func didCancelRequest()
}

public final class HackrNewFeedCellController: StoryView, StoryLoadingView, StoryErrorView {
    private let delegate: HackrNewFeedCellControllerDelegate
    private let didSelectStory: () -> Void
    private var cell: HackrNewFeedCell?

    public init(delegate: HackrNewFeedCellControllerDelegate, didSelectStory: @escaping () -> Void) {
        self.delegate = delegate
        self.didSelectStory = didSelectStory
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: "HackrNewFeedCell") as? HackrNewFeedCell
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestStory()
        }
        delegate.didRequestStory()
        return cell!
    }

    func preload() {
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
        cell?.id = viewModel.newId
        cell?.url = viewModel.url
        cell?.titleLabel.text = viewModel.title
        cell?.urlLabel.text = viewModel.displayURL
        cell?.authorLabel.text = viewModel.author
        cell?.commentsLabel.text = viewModel.comments
        cell?.scoreLabel.text = viewModel.score
        cell?.createdAtLabel.text = viewModel.date
        cell?.retryLoadStoryButton.isHidden = true
    }

    public func display(_ viewModel: StoryErrorViewModel) {
        cell?.retryLoadStoryButton.isHidden = (viewModel.error == nil)
        cell?.mainContainer.isHidden = !(viewModel.error == nil)
    }

    func didSelect() {
        didSelectStory()
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
