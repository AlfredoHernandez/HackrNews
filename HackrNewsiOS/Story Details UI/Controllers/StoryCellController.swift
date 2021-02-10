//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public final class StoryCellController {
    private(set) var cell: StoryDetailCell?
    private let viewModel: StoryDetailViewModel
    private let didSelect: (() -> Void)?

    public init(viewModel: StoryDetailViewModel, didSelect: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.didSelect = didSelect
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.titleLabel.text = viewModel.title
        cell?.authorLabel.text = viewModel.author
        cell?.scoreLabel.text = viewModel.score
        cell?.commentsLabel.text = viewModel.comments
        cell?.createdAtLabel.text = viewModel.createdAt
        cell?.urlLabel.text = viewModel.displayURL
        return cell!
    }

    func releaseCellForReuse() {
        cell = nil
    }

    func selection() {
        didSelect?()
    }
}
