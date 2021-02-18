//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class HackrStoryLoaderCacheDecorator {
    init(decoratee _: HackrStoryLoader, cache _: HackrStoryCache) {}
}

final class HackrStoryLoaderCacheDecoratorTests: XCTestCase {
    func test_init_doesNotLoadStoryData() {
        let loader = HackrStoryLoaderSpy()
        let cache = HackrStoryCacheSpy()
        _ = HackrStoryLoaderCacheDecorator(decoratee: loader, cache: cache)

        XCTAssertEqual(loader.loadedStories, [], "Expected to not load a story")
    }

    private class HackrStoryCacheSpy: HackrStoryCache {
        func save(_: Story, completion _: @escaping (HackrStoryCache.SaveResult) -> Void) {}
    }
}
