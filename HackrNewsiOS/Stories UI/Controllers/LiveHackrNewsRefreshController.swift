//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

final class LiveHackrNewsModel {
    private let loader: LiveHackrNewsLoader

    init(loader: LiveHackrNewsLoader) {
        self.loader = loader
    }

    private enum State {
        case pending
        case loading
        case loaded([LiveHackrNew])
        case failed
    }

    private var state: State = .pending {
        didSet {
            onChange?(self)
        }
    }

    var onChange: ((LiveHackrNewsModel) -> Void)?

    var isLoading: Bool {
        switch state {
        case .loading: return true
        case .pending, .loaded, .failed: return false
        }
    }

    var news: [LiveHackrNew]? {
        switch state {
        case let .loaded(news): return news
        case .pending, .loading, .failed: return nil
        }
    }

    func loadNews() {
        loader.load { [weak self] result in
            if let news = try? result.get() {
                self?.state = .loaded(news)
            } else {
                self?.state = .failed
            }
        }
    }
}

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

    var onRefresh: (([LiveHackrNew]) -> Void)?

    @objc func refresh() {
        view.beginRefreshing()
        loader.load { [weak self] result in
            if let news = try? result.get() {
                self?.onRefresh?(news)
            }
            self?.view.endRefreshing()
        }
    }
}
