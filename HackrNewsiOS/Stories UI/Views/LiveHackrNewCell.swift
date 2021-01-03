//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SkeletonView
import UIKit

public class LiveHackrNewCell: UITableViewCell {
    public var id: Int = 0
    public var url: URL?
    @IBOutlet public private(set) var container: UIView!
    @IBOutlet public var leftContainer: UIStackView!
    @IBOutlet public var middleContainer: UIStackView!
    @IBOutlet public var rightContainer: UIStackView!
    @IBOutlet public private(set) var titleLabel: UILabel!
    @IBOutlet public private(set) var authorLabel: UILabel!
    @IBOutlet public private(set) var scoreLabel: UILabel!
    @IBOutlet public private(set) var commentsLabel: UILabel!
    @IBOutlet public private(set) var createdAtLabel: UILabel!
    @IBOutlet public private(set) var retryLoadStoryButton: UIButton!

    public var isLoadingContent: Bool = false {
        willSet {
            if newValue {
                container.showAnimatedGradientSkeleton()
            } else {
                container.hideSkeleton(transition: .crossDissolve(0.5))
            }
        }
    }

    var onRetry: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
