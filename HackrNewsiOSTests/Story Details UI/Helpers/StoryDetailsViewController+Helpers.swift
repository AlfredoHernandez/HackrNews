//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
@testable import HackrNewsiOS
import UIKit

extension StoryDetailsViewController {
    var storyDetailsView: StoryDetailCell? {
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: storyDetailSection)) as? StoryDetailCell
    }

    var storyTextView: UITableViewCell? {
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: storyDetailSection))
    }

    @discardableResult
    func simulateStoryDetailViewVisible() -> StoryDetailCell? {
        storyDetailsView
    }

    func simulateStoryDetailViewNotVisible() {
        let delegate = tableView.delegate
        delegate?.tableView?(tableView, didEndDisplaying: storyDetailsView!, forRowAt: IndexPath(row: 0, section: storyDetailSection))
    }

    var titleText: String? {
        storyDetailsView?.titleLabel.text
    }

    var authorText: String? {
        storyDetailsView?.authorLabel.text
    }

    var scoreText: String? {
        storyDetailsView?.scoreLabel.text
    }

    var commentsText: String? {
        storyDetailsView?.commentsLabel.text
    }

    var createdAtText: String? {
        storyDetailsView?.createdAtLabel.text
    }

    var urlText: String? {
        storyDetailsView?.urlLabel.text
    }

    var bodyText: String? {
        storyTextView?.textLabel?.text
    }

    var commentsTitle: String? {
        tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: storyCommentsSection)
    }

    var detailViewIsReusable: Bool {
        storyCellController.cell == nil
    }

    func numberOfRenderedComments() -> Int {
        tableView.numberOfRows(inSection: storyCommentsSection)
    }

    func commentView(at row: Int = 0) -> UITableViewCell? {
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: storyCommentsSection))
    }

    private var storyDetailSection: Int { 0 }

    private var storyCommentsSection: Int { 1 }
}
