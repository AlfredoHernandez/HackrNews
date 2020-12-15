//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

final class LiveHackrNewCellController {
    private var task: HackrStoryLoaderTask?
    private let loader: HackrStoryLoader
    private let model: LiveHackrNew

    init(model: LiveHackrNew, loader: HackrStoryLoader) {
        self.model = model
        self.loader = loader
    }

    func view() -> UITableViewCell {
        let cell = LiveHackrNewCell()
        cell.id = model.id
        cell.container.isShimmering = true
        cell.retryLoadStoryButton.isHidden = true
        let loadStory = { [weak self, weak cell] in
            guard let self = self else { return }
            self.task = self.loader.load(from: self.model.url) { [weak cell] result in
                let data = try? result.get()
                cell?.retryLoadStoryButton.isHidden = (data != nil)
                cell?.titleLabel.text = data?.title
                cell?.authorLabel.text = data?.author
                cell?.scoreLabel.text = data?.score.description
                cell?.commentsLabel.text = data?.comments.description
                cell?.container.isShimmering = false
            }
        }
        loadStory()
        cell.onRetry = loadStory
        return cell
    }

    func preload() {
        task = loader.load(from: model.url) { _ in }
    }

    deinit {
        task?.cancel()
    }
}
