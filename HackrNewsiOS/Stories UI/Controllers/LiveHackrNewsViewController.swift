//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class LiveHackrNewsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var liveHackrNewsloader: LiveHackrNewsLoader?
    private var hackrStoryLoader: HackrStoryLoader?
    private var refreshController: LiveHackrNewsRefreshController?
    var tableModel = [LiveHackrNew]() {
        didSet { tableView.reloadData() }
    }

    var tasks = [IndexPath: HackrStoryLoaderTask]()

    public convenience init(loader: LiveHackrNewsLoader, hackrStoryLoader: HackrStoryLoader) {
        self.init()
        liveHackrNewsloader = loader
        self.hackrStoryLoader = hackrStoryLoader
        refreshController = LiveHackrNewsRefreshController(loader: loader)
    }

    override public func viewDidLoad() {
        tableView.prefetchDataSource = self
        tableView.refreshControl = refreshController?.view
        refreshController?.refresh()
        refreshController?.onLoad = { [weak self] stories in
            self?.tableModel = stories
        }
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
        cancelTask(at: indexPath)
    }

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            tasks[indexPath] = hackrStoryLoader?.load(from: cellModel.url, completion: { _ in })
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }

    private func cancelTask(at indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
