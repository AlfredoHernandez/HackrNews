//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

public class LiveHackrNewCell: UITableViewCell {
    public var id: Int = 0
    @IBOutlet public private(set) var container: UIView!
    @IBOutlet public private(set) var titleLabel: UILabel!
    @IBOutlet public private(set) var authorLabel: UILabel!
    @IBOutlet public private(set) var scoreLabel: UILabel!
    @IBOutlet public private(set) var commentsLabel: UILabel!
    @IBOutlet public private(set) var createdAtLabel: UILabel!
    @IBOutlet public private(set) var retryLoadStoryButton: UIButton!

    var onRetry: (() -> Void)?

    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
