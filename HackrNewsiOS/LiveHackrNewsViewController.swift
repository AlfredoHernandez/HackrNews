//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class LiveHackrNewCell: UITableViewCell {
    public var id: Int = 0
}

public class LiveHackrNewsViewController: UITableViewController {
    private var loader: LiveHackrNewsLoader?
    var tableModel = [LiveHackerNew]()

    public convenience init(loader: LiveHackrNewsLoader) {
        self.init()
        self.loader = loader
    }

    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
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
        cell.id = tableModel[indexPath.row]
        return cell
    }
}
