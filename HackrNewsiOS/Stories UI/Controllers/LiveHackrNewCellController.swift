//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

final class LiveHackrNewCellController {
    let viewModel: LiveHackrNewViewModel

    init(viewModel: LiveHackrNewViewModel) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = binded(LiveHackrNewCell())
        viewModel.load()
        return cell
    }

    func preload() {
        viewModel.preload()
    }

    func cancelLoad() {
        viewModel.cancelLoad()
    }

    private func binded(_: UITableViewCell) -> UITableViewCell {
        let cell = LiveHackrNewCell()
        cell.onRetry = viewModel.load
        cell.id = viewModel.storyId

        viewModel.onShouldRetryLoadStory = { [weak cell] shouldRetry in
            cell?.retryLoadStoryButton.isHidden = !shouldRetry
        }

        viewModel.onLoadingStateChanged = { [weak cell] isLoading in
            cell?.container.isShimmering = isLoading
        }

        viewModel.onStoryLoad = { [weak cell] story in
            cell?.titleLabel.text = story.title
            cell?.authorLabel.text = story.author
            cell?.scoreLabel.text = story.score.description
            cell?.commentsLabel.text = story.comments.description
        }
        return cell
    }
}
