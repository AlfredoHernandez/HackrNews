//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol LiveHackrNewCellControllerDelegate {
    func didRequestStory()
    func didCancelRequest()
}

public final class HackrNewFeedCellController: StoryView, StoryLoadingView, StoryErrorView {
    private let delegate: LiveHackrNewCellControllerDelegate
    private let didSelectStory: (URL) -> Void
    private var cell: LiveHackrNewCell?

    public init(delegate: LiveHackrNewCellControllerDelegate, didSelectStory: @escaping (URL) -> Void) {
        self.delegate = delegate
        self.didSelectStory = didSelectStory
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: "LiveHackrNewCell") as? LiveHackrNewCell
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
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestStory()
        }
    }

    public func display(_ viewModel: StoryErrorViewModel) {
        cell?.retryLoadStoryButton.isHidden = (viewModel.message == nil)
        cell?.mainContainer.isHidden = !(viewModel.message == nil)
    }

    func didSelect() {
        guard let url = cell?.url else { return }
        didSelectStory(url)
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
