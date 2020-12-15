//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

final class LiveHackrNewsViewModel {
    private let loader: LiveHackrNewsLoader

    init(loader: LiveHackrNewsLoader) {
        self.loader = loader
    }

    var onChange: ((LiveHackrNewsViewModel) -> Void)?
    var onLoad: (([LiveHackrNew]) -> Void)?

    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }

    func loadNews() {
        isLoading = true
        loader.load { [weak self] result in
            if let news = try? result.get() {
                self?.onLoad?(news)
            }
            self?.isLoading = false
        }
    }
}
