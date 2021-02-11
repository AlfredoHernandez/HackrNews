//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SkeletonView
import UIKit

public class HackrNewFeedCell: UITableViewCell {
    public var url: URL?

    public private(set) lazy var mainContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, urlLabel, middleContainer, footerContainer])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 2
        view.distribution = .equalSpacing
        view.isSkeletonable = true
        return view
    }()

    public private(set) lazy var middleContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [authorLabel, createdAtLabel])
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .fill
        view.isSkeletonable = true
        return view
    }()

    public private(set) lazy var footerContainer: UIStackView = {
        let view = UIStackView(arrangedSubviews: [scoreLabel, commentsLabel])
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .fill
        view.distribution = .fill
        view.isSkeletonable = true
        return view
    }()

    public private(set) var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore."
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.isSkeletonable = true
        return label
    }()

    public private(set) var urlLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .hackrNews
        label.text = "Lorem ipsum"
        label.adjustsFontForContentSizeCategory = true
        label.isSkeletonable = true
        return label
    }()

    public private(set) var authorLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.text = "Lorem ipsum"
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.isSkeletonable = true
        return label
    }()

    public private(set) var createdAtLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        label.text = "Lorem ipsum"
        label.adjustsFontForContentSizeCategory = true
        label.isSkeletonable = true
        return label
    }()

    public private(set) var scoreLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        label.text = "Lorem ipsum"
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.isSkeletonable = true
        return label
    }()

    public private(set) var commentsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        label.text = "Lorem ipsum"
        label.adjustsFontForContentSizeCategory = true
        label.isSkeletonable = true
        return label
    }()

    public private(set) lazy var retryLoadStoryButton: UIButton = {
        let button = UIButton()
        button.isSkeletonable = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("↻", for: .normal)
        button.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 60)
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

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
            mainContainer.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 8),
            mainContainer.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])

        contentView.addSubview(errorContentView)
        NSLayoutConstraint.activate([
            errorContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            errorContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            errorContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        errorContentView.addSubview(retryLoadStoryButton)
        NSLayoutConstraint.activate([
            retryLoadStoryButton.leadingAnchor.constraint(equalTo: errorContentView.leadingAnchor),
            retryLoadStoryButton.trailingAnchor.constraint(equalTo: errorContentView.trailingAnchor),
            retryLoadStoryButton.topAnchor.constraint(equalTo: errorContentView.topAnchor),
            retryLoadStoryButton.bottomAnchor.constraint(equalTo: errorContentView.bottomAnchor),
        ])
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
