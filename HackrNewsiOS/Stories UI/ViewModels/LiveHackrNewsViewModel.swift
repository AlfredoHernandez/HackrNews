//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

final class LiveHackrNewsViewModel {
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

    var onChange: ((LiveHackrNewsViewModel) -> Void)?

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
