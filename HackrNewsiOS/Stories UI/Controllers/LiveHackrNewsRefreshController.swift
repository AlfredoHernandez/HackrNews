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
    private(set) lazy var view = binded(UIRefreshControl())

    private let viewModel: LiveHackrNewsModel

    init(loader: LiveHackrNewsLoader) {
        viewModel = LiveHackrNewsModel(loader: loader)
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
