//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

public class LiveHackrNewCell: UITableViewCell {
    public var id: Int = 0
    public let container = UIView()
    public let titleLabel = UILabel()
    public let authorLabel = UILabel()
    public let scoreLabel = UILabel()
    public let commentsLabel = UILabel()
    public let createdAtLabel = UILabel()

    public private(set) lazy var retryLoadStoryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?

    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
