//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit
import SkeletonView

public class LiveHackrNewCell: UITableViewCell {
    public var id: Int = 0
    @IBOutlet public private(set) var container: UIView!
    @IBOutlet weak var leftContainer: UIStackView!
    @IBOutlet weak var middleContainer: UIStackView!
    @IBOutlet weak var rightContainer: UIStackView!
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
    
    public override func awakeFromNib() {
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
