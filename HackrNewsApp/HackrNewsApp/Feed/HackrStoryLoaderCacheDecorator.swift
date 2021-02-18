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
        decoratee.load(id: id) { [weak self] result in
            completion(result.map { story in
                self?.cache.saveIgnoringResults(story: story)
                return story
            })
        }
    }
}

extension HackrStoryCache {
    func saveIgnoringResults(story: Story) {
        save(story) { _ in }
    }
}
