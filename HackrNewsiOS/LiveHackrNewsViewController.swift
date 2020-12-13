//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class LiveHackrNewCell: UITableViewCell {
    public var id: Int = 0
}

public class LiveHackrNewsViewController: UITableViewController {
    private var liveHackrNewsloader: LiveHackrNewsLoader?
    private var hackrStoryLoader: HackrStoryLoader?
    var tableModel = [LiveHackrNew]()

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
        hackrStoryLoader?.load(from: model.url) { _ in }
        return cell
    }
}
