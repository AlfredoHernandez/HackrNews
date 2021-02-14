//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

class HackrNewsFeedLoaderCacheDecorator: HackrNewsFeedLoader {
    private let decoratee: HackrNewsFeedLoader
    private let cache: HackrNewsFeedCache

    init(decoratee: HackrNewsFeedLoader, cache: HackrNewsFeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func load(completion: @escaping (HackrNewsFeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.save(feed, completion: { _ in })
                return feed
            })
        }
    }
}
