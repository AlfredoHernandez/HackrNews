//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
@testable import HackrNewsiOS

extension StoryDetailsViewController {
    var storyDetailsView: StoryDetailCell? {
        tableView.cellForRow(at: IndexPath(row: 0, section: storyDetailSection)) as? StoryDetailCell
    }

    var titleText: String? {
        storyDetailsView?.titleLabel.text
    }

    var text: String? {
        storyDetailsView?.bodyLabel.text
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

    private var storyDetailSection: Int { 0 }
}
