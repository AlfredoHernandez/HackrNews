//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol LiveHackrNewCellControllerDelegate {
    func didRequestStory()
    func didCancelRequest()
}

final class LiveHackrNewCellController: StoryView, StoryLoadingView, StoryErrorView {
    private let delegate: LiveHackrNewCellControllerDelegate
    private var cell: LiveHackrNewCell?

    init(delegate: LiveHackrNewCellControllerDelegate) {
        self.delegate = delegate
    }

    func view() -> UITableViewCell {
        cell = LiveHackrNewCell()
        delegate.didRequestStory()
        return cell!
    }

    func preload() {
        delegate.didRequestStory()
    }

    func cancelLoad() {
        delegate.didCancelRequest()
    }

    func display(_ viewModel: StoryLoadingViewModel) {
        cell?.container.isShimmering = viewModel.isLoading
    }

    func display(_ viewModel: StoryViewModel) {
        cell?.id = viewModel.newId
        cell?.titleLabel.text = viewModel.title
        cell?.authorLabel.text = viewModel.author
        cell?.commentsLabel.text = viewModel.comments
        cell?.scoreLabel.text = viewModel.score
        cell?.onRetry = { [weak self] in
            self?.delegate.didRequestStory()
        }
    }

    func display(_ viewModel: StoryErrorViewModel) {
        cell?.retryLoadStoryButton.isHidden = (viewModel.message == nil)
    }
}
