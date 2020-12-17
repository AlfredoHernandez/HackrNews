//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

final class LiveHackrNewsRefreshController: NSObject, LiveHackrNewsLoadingView {
    private(set) lazy var view = loadView()

    private let loadNews: () -> Void

    init(loadNews: @escaping (() -> Void)) {
        self.loadNews = loadNews
    }

    @objc func refresh() {
        view.beginRefreshing()
        loadNews()
    }

    func display(_ viewModel: LiveHackrNewsLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }

    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
