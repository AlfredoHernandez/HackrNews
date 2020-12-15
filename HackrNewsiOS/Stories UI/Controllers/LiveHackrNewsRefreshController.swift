//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

final class LiveHackrNewsRefreshController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    private let loader: LiveHackrNewsLoader

    init(loader: LiveHackrNewsLoader) {
        self.loader = loader
    }

    var onLoad: (([LiveHackrNew]) -> Void)?

    @objc func refresh() {
        view.beginRefreshing()
        loader.load { [weak self] result in
            if let news = try? result.get() {
                self?.onLoad?(news)
            }
            self?.view.endRefreshing()
        }
    }
}
