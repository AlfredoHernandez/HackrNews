//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SkeletonView
import UIKit

public class CommentCell: UITableViewCell {
    private lazy var mainContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [headerContainer, bodyLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 4.0
        view.distribution = .fill
        view.isSkeletonable = true
        return view
    }()

    private lazy var headerContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [authorLabel, createdAtLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .equalCentering
        view.isSkeletonable = true
        return view
    }()

    public private(set) var authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .hackrNews
        label.text = "Lorem ipsum"
        label.isSkeletonable = true
        return label
    }()

    public private(set) var createdAtLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        label.text = "Lorem ipsum"
        label.isSkeletonable = true
        return label
    }()

    public private(set) lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore."
        label.isSkeletonable = true
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
            mainContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            mainContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            mainContainer.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        selectionStyle = .none
    }

    public var isLoadingContent: Bool = false {
        willSet {
            if newValue {
                mainContainer.showAnimatedGradientSkeleton()
            } else {
                mainContainer.hideSkeleton()
            }
        }
    }
}
