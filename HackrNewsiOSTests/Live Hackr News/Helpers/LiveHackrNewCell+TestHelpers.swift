//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNewsiOS
import UIKit

extension LiveHackrNewCell {
    var cellId: Int { id }

    var isShowingLoadingIndicator: Bool { isLoadingContent }

    var containerView: UIView? {
        container
    }

    var leftContainerView: UIView? {
        leftContainer
    }

    var middleContainerView: UIView? {
        middleContainer
    }

    var rightContainerView: UIView? {
        rightContainer
    }

    var titleView: UIView? {
        titleLabel
    }

    var titleText: String? {
        titleLabel.text
    }

    var authorView: UIView? {
        authorLabel
    }

    var authorText: String? {
        authorLabel.text
    }

    var scoreView: UIView? {
        scoreLabel
    }

    var scoreText: String? {
        scoreLabel.text
    }

    var commentsView: UIView? {
        commentsLabel
    }

    var commentsText: String? {
        commentsLabel.text
    }

    var createdAtView: UIView? {
        createdAtLabel
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
