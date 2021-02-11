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
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore."
        label.isSkeletonable = true
        return label
    }()

    public private(set) lazy var retryButton: UIButton = {
        let button = UIButton()
        button.isSkeletonable = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("↻", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        button.setTitleColor(.hackrNews, for: .normal)
        return button
    }()

    public private(set) lazy var errorContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
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
        contentView.addSubview(mainContainer)
        NSLayoutConstraint.activate([
            mainContainer.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainContainer.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            mainContainer.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainContainer.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

        contentView.addSubview(errorContentView)
        NSLayoutConstraint.activate([
            errorContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            errorContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            errorContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        errorContentView.addSubview(retryButton)
        NSLayoutConstraint.activate([
            retryButton.leadingAnchor.constraint(equalTo: errorContentView.leadingAnchor),
            retryButton.trailingAnchor.constraint(equalTo: errorContentView.trailingAnchor),
            retryButton.topAnchor.constraint(equalTo: errorContentView.topAnchor),
            retryButton.bottomAnchor.constraint(equalTo: errorContentView.bottomAnchor),
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
