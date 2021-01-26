//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol LiveHackrNewsRefreshControllerDelegate {
    func didRequestNews()
}

public final class LiveHackrNewsRefreshController: NSObject, HackrNewsFeedLoadingView {
    private(set) lazy var view = loadView()

    private let delegate: LiveHackrNewsRefreshControllerDelegate

    public init(delegate: LiveHackrNewsRefreshControllerDelegate) {
        self.delegate = delegate
    }

    @objc func refresh() {
        delegate.didRequestNews()
    }

    public func display(_ viewModel: HackrNewsFeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }

    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        view.tintColor = UIColor.hackerNews
        return view
    }
}
