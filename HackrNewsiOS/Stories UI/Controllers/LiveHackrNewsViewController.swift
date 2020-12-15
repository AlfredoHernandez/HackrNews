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

    var cellControllers = [IndexPath: LiveHackrNewCellController]()

    public convenience init(liveHackrNewsloader: LiveHackrNewsLoader, hackrStoryLoader: HackrStoryLoader) {
        self.init()
        self.liveHackrNewsloader = liveHackrNewsloader
        self.hackrStoryLoader = hackrStoryLoader
        refreshController = LiveHackrNewsRefreshController(loader: liveHackrNewsloader)
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
        cellController(forRowAt: indexPath).view()
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(at: indexPath)
    }

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> LiveHackrNewCellController {
        let model = tableModel[indexPath.row]
        let cellController = LiveHackrNewCellController(model: model, loader: hackrStoryLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }

    private func removeCellController(at indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
