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

    var titleView: UILabel? {
        titleLabel
    }

    var titleText: String? {
        titleView?.text
    }

    var authorView: UILabel? {
        authorLabel
    }

    var authorText: String? {
        authorView?.text
    }

    var scoreView: UILabel? {
        scoreLabel
    }

    var scoreText: String? {
        scoreView?.text
    }

    var commentsView: UILabel? {
        commentsLabel
    }

    var commentsText: String? {
        commentsView?.text
    }

    var createdAtView: UILabel? {
        createdAtLabel
    }

    var createdAtText: String? {
        createdAtView?.text
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
