//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public final class StoryCellController {
    private(set) var cell: StoryDetailCell?
    private let viewModel: StoryDetailViewModel

    public init(viewModel: StoryDetailViewModel) {
        self.viewModel = viewModel
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

    var bodyText: String? { viewModel.text }

    func releaseCellForReuse() {
        cell = nil
    }
}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
