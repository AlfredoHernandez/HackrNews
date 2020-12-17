//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

protocol LiveHackrNewsRefreshControllerDelegate {
    func didRequestNews()
}

final class LiveHackrNewsRefreshController: NSObject, LiveHackrNewsLoadingView {
    private(set) lazy var view = loadView()

    private let delegate: LiveHackrNewsRefreshControllerDelegate

    init(delegate: LiveHackrNewsRefreshControllerDelegate) {
        self.delegate = delegate
    }

    @objc func refresh() {
        delegate.didRequestNews()
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
