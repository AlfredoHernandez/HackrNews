//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class LiveHackrNewsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: LiveHackrNewsRefreshController?
    private(set) var tableModel = [LiveHackrNewCellController]() {
        didSet { tableView.reloadData() }
    }

    convenience init(refreshController: LiveHackrNewsRefreshController) {
        self.init()
        self.refreshController = refreshController
    }

    override public func viewDidLoad() {
        tableView.prefetchDataSource = self
        tableView.register(
            UINib(nibName: "LiveHackrNewCell", bundle: Bundle(for: LiveHackrNewCell.self)),
            forCellReuseIdentifier: "LiveHackrNewCell"
        )
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshController?.view
        refreshController?.refresh()
    }

    public func display(_ cellControllers: [LiveHackrNewCellController]) {
        tableModel = cellControllers
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(in: tableView)
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

extension LiveHackrNewsViewController: LiveHackrNewsErrorView {
    public func display(_: LiveHackrNewsErrorViewModel) {
        // TODO: Display error message
    }
}
