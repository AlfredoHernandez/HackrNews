//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

final class LiveHackrNewsRefreshController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())

    private let viewModel: LiveHackrNewsViewModel

    init(loader: LiveHackrNewsLoader) {
        viewModel = LiveHackrNewsViewModel(loader: loader)
    }

    var onRefresh: (([LiveHackrNew]) -> Void)?

    @objc func refresh() {
        view.beginRefreshing()
        viewModel.loadNews()
    }

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }

            if let news = viewModel.news {
                self?.onRefresh?(news)
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
