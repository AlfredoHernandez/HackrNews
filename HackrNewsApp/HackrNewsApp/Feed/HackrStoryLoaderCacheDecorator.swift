//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

class HackrStoryLoaderCacheDecorator: HackrStoryLoader {
    private let decoratee: HackrStoryLoader
    private let cache: HackrStoryCache

    init(decoratee: HackrStoryLoader, cache: HackrStoryCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func load(id: Int, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
        decoratee.load(id: id) { [unowned self] result in
            switch result {
            case let .success(story):
                self.cache.save(story) { _ in }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
