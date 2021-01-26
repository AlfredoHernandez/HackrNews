//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public protocol HackrNewsFeedRefreshControllerDelegate {
    func didRequestNews()
}

public final class HackrNewsFeedRefreshController: NSObject, HackrNewsFeedLoadingView {
    private(set) lazy var view = loadView()

    private let delegate: HackrNewsFeedRefreshControllerDelegate

    public init(delegate: HackrNewsFeedRefreshControllerDelegate) {
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
        view.tintColor = UIColor.hackrNews
        return view
    }
}
