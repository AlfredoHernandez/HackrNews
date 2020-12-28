//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SkeletonView
import UIKit

public class LiveHackrNewCell: UITableViewCell {
    public var id: Int = 0
    @IBOutlet public private(set) var container: UIView!
    @IBOutlet var leftContainer: UIStackView!
    @IBOutlet var middleContainer: UIStackView!
    @IBOutlet var rightContainer: UIStackView!
    @IBOutlet public private(set) var titleLabel: UILabel!
    @IBOutlet public private(set) var authorLabel: UILabel!
    @IBOutlet public private(set) var scoreLabel: UILabel!
    @IBOutlet public private(set) var commentsLabel: UILabel!
    @IBOutlet public private(set) var createdAtLabel: UILabel!
    @IBOutlet public private(set) var retryLoadStoryButton: UIButton!

    public var isLoadingContent: Bool = false {
        willSet {
            if newValue {
                container.showSkeleton()
            } else {
                container.hideSkeleton()
            }
        }
    }

    var onRetry: (() -> Void)?

    override public func awakeFromNib() {
        super.awakeFromNib()
        container.isSkeletonable = true
        leftContainer.isSkeletonable = true
        middleContainer.isSkeletonable = true
        rightContainer.isSkeletonable = true
        titleLabel.isSkeletonable = true
        authorLabel.isSkeletonable = true
        scoreLabel.isSkeletonable = true
        commentsLabel.isSkeletonable = true
        createdAtLabel.isSkeletonable = true
    }

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
