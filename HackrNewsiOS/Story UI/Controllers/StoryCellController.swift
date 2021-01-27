//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

final class StoryCellController {
    private var locale = Locale.current
    private var calendar = Calendar(identifier: .gregorian)
    private let model: StoryDetail

    init(model: StoryDetail) {
        self.model = model
    }

    func view() -> UITableViewCell {
        let cell = StoryDetailCell()
        cell.titleLabel.text = model.title
        cell.authorLabel.text = model.author
        cell.scoreLabel.text = "\(model.score) points"
        cell.commentsLabel.text = "\(model.totalComments) comments"
        cell.createdAtLabel.text = format(from: model.createdAt)
        cell.urlLabel.text = model.url.host
        return cell
    }

    private func format(from date: Date) -> String? {
        let dateFormatter = RelativeDateTimeFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        return dateFormatter.string(for: date)
    }
}
