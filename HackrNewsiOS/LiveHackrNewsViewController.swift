//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
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

public class LiveHackrNewsViewController: UITableViewController {
    private var liveHackrNewsloader: LiveHackrNewsLoader?
    private var hackrStoryLoader: HackrStoryLoader?
    var tableModel = [LiveHackrNew]()
    var tasks = [IndexPath: HackrStoryLoaderTask]()

    public convenience init(loader: LiveHackrNewsLoader, hackrStoryLoader: HackrStoryLoader) {
        self.init()
        liveHackrNewsloader = loader
        self.hackrStoryLoader = hackrStoryLoader
    }

    @objc func load() {
        refreshControl?.beginRefreshing()
        liveHackrNewsloader?.load { [weak self] result in
            if let news = try? result.get() {
                self?.tableModel = news
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }

    override public func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = LiveHackrNewCell()
        let model = tableModel[indexPath.row]
        cell.id = model.id
        cell.container.isShimmering = true
        cell.retryLoadStoryButton.isHidden = true
        let loadStory = { [weak self, weak cell] in
            guard let self = self else { return }
            self.tasks[indexPath] = self.hackrStoryLoader?.load(from: model.url) { [weak cell] result in
                let data = try? result.get()
                cell?.retryLoadStoryButton.isHidden = (data != nil)
                cell?.titleLabel.text = data?.title
                cell?.authorLabel.text = data?.author
                cell?.scoreLabel.text = data?.score.description
                cell?.commentsLabel.text = data?.comments.description
                cell?.container.isShimmering = false
            }
        }
        loadStory()
        cell.onRetry = loadStory
        return cell
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
