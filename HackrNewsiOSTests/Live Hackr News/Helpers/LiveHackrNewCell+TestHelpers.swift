//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNewsiOS

extension LiveHackrNewCell {
    var cellId: Int { id }

    var isShowingLoadingIndicator: Bool { isLoadingContent }

    var titleText: String? {
        titleLabel.text
    }

    var authorText: String? {
        authorLabel.text
    }

    var scoreText: String? {
        scoreLabel.text
    }

    var commentsText: String? {
        commentsLabel.text
    }

    var createdAtText: String? {
        createdAtLabel.text
    }

    var isShowingRetryAction: Bool {
        !retryLoadStoryButton.isHidden
    }

    var isShowingStoryContainer: Bool {
        !container.isHidden
    }

    func simulateRetryAction() {
        retryLoadStoryButton.simulateTap()
    }
}
