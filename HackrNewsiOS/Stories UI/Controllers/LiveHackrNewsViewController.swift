//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

public class LiveHackrNewsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: LiveHackrNewsRefreshController?
    var tableModel = [LiveHackrNewCellController]() {
        didSet { tableView.reloadData() }
    }

    convenience init(refreshController: LiveHackrNewsRefreshController) {
        self.init()
        self.refreshController = refreshController
    }

    override public func viewDidLoad() {
        tableView.prefetchDataSource = self
        tableView.refreshControl = refreshController?.view
        refreshController?.refresh()
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view()
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(at: indexPath)
    }

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> LiveHackrNewCellController {
        tableModel[indexPath.row]
    }

    private func cancelCellControllerLoad(at indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
