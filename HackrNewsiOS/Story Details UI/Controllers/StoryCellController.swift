//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public final class StoryCellController {
    private let viewModel: StoryDetailViewModel

    public init(viewModel: StoryDetailViewModel) {
        self.viewModel = viewModel
    }

    func view() -> UITableViewCell {
        let cell = StoryDetailCell()
        cell.titleLabel.text = viewModel.title
        cell.authorLabel.text = viewModel.author
        cell.scoreLabel.text = viewModel.score
        cell.commentsLabel.text = viewModel.comments
        cell.createdAtLabel.text = viewModel.createdAt
        cell.urlLabel.text = viewModel.displayURL
        return cell
    }
}
