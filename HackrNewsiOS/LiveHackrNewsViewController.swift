//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class LiveHackrNewsViewController: UITableViewController {
    private var loader: LiveHackrNewsLoader?

    public convenience init(loader: LiveHackrNewsLoader) {
        self.init()
        self.loader = loader
    }

    @objc func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }

    override public func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
}
