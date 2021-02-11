//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNewsiOS
import UIKit

extension HackrNewFeedCell {
    var cellId: Int { id }

    var isShowingLoadingIndicator: Bool { isLoadingContent }

    var containerView: UIView? {
        mainContainer
    }

    var middleContainerView: UIView? {
        middleContainer
    }

    var storyUserInfoView: UIView? {
        footerContainer
    }

    var titleView: UILabel? {
        titleLabel
    }

    var titleText: String? {
        titleView?.text
    }

    var urlText: String? {
        urlLabel.text
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
        !errorContentView.isHidden
    }

    func simulateTapOnRetryIndicator() {
        retryLoadStoryButton.simulateTap()
    }
}
