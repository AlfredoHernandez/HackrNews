//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol LiveHackrNewCellControllerDelegate {
    func didRequestStory()
    func didCancelRequest()
}

public final class LiveHackrNewCellController: StoryView, StoryLoadingView, StoryErrorView {
    private let delegate: LiveHackrNewCellControllerDelegate
    private var cell: LiveHackrNewCell?

    public init(delegate: LiveHackrNewCellControllerDelegate) {
        self.delegate = delegate
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
        delegate.didCancelRequest()
    }

    public func display(_ viewModel: StoryLoadingViewModel) {
        cell?.container.isShimmering = viewModel.isLoading
    }

    public func display(_ viewModel: StoryViewModel) {
        cell?.id = viewModel.newId
        cell?.titleLabel.text = viewModel.title
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
        cell?.container.isHidden = !(viewModel.message == nil)
    }
}
