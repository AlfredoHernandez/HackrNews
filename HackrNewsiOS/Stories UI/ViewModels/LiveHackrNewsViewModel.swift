//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

final class LiveHackrNewsViewModel {
    typealias Observer<T> = (T) -> Void
    private let loader: LiveHackrNewsLoader

    init(loader: LiveHackrNewsLoader) {
        self.loader = loader
    }

    var onLoadingStateChange: Observer<Bool>?
    var onLoad: Observer<[LiveHackrNew]>?

    func loadNews() {
        onLoadingStateChange?(true)
        loader.load { [weak self] result in
            if let news = try? result.get() {
                self?.onLoad?(news)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
