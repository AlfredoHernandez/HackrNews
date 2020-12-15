//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

final class LiveHackrNewsRefreshController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())

    private let viewModel: LiveHackrNewsViewModel

    init(viewModel: LiveHackrNewsViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        view.beginRefreshing()
        viewModel.loadNews()
    }

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { viewModel in
            if viewModel.isLoading {
                view.beginRefreshing()
            } else {
                view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
