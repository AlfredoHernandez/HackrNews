//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

final class LiveHackrNewsRefreshController: NSObject, LiveHackrNewsLoadingView {
    private(set) lazy var view = loadView()

    private let liveHackrNewsPresenter: LiveHackrNewsPresenter

    init(liveHackrNewsPresenter: LiveHackrNewsPresenter) {
        self.liveHackrNewsPresenter = liveHackrNewsPresenter
    }

    @objc func refresh() {
        view.beginRefreshing()
        liveHackrNewsPresenter.loadNews()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
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
