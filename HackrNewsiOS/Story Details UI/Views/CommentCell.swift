//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    private lazy var mainContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [headerContainer, bodyLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 4.0
        view.distribution = .fill
        return view
    }()

    private lazy var headerContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [authorLabel, createdAtLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        return view
    }()

    public private(set) var authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()

    public private(set) var createdAtLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    public private(set) lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(mainContainer)
        NSLayoutConstraint.activate([
            mainContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainContainer.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            mainContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
        selectionStyle = .none
    }
}
