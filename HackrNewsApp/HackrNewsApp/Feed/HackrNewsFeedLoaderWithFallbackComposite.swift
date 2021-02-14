//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

class HackrNewsFeedLoaderWithFallbackComposite: HackrNewsFeedLoader {
    private let primary: HackrNewsFeedLoader
    private let fallback: HackrNewsFeedLoader

    init(primary: HackrNewsFeedLoader, fallback: HackrNewsFeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func load(completion: @escaping (HackrNewsFeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case let .success(feed):
                completion(.success(feed))
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
