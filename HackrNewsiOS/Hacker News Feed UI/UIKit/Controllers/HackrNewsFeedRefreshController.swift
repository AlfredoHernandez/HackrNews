//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public final class HackrNewsFeedRefreshController: NSObject, ResourceLoadingView {
    private(set) lazy var view = loadView()
    public var didRequestNews: (() -> Void)?

    @objc func refresh() {
        didRequestNews?()
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
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
