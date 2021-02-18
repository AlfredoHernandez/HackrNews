//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class HackrStoryLoaderCacheDecorator: HackrStoryLoader {
    private let decoratee: HackrStoryLoader
    init(decoratee: HackrStoryLoader, cache _: HackrStoryCache) {
        self.decoratee = decoratee
    }

    func load(id: Int, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
        decoratee.load(id: id, completion: completion)
    }
}

final class HackrStoryLoaderCacheDecoratorTests: XCTestCase {
    func test_init_doesNotLoadStoryData() {
        let loader = HackrStoryLoaderSpy()
        let cache = HackrStoryCacheSpy()
        _ = HackrStoryLoaderCacheDecorator(decoratee: loader, cache: cache)

        XCTAssertEqual(loader.loadedStories, [], "Expected to not load a story")
    }

    func test_load_loadsFromLoader() {
        let loader = HackrStoryLoaderSpy()
        let cache = HackrStoryCacheSpy()
        let sut = HackrStoryLoaderCacheDecorator(decoratee: loader, cache: cache)
        let id = anyID()

        _ = sut.load(id: id) { _ in }

        XCTAssertEqual(loader.loadedStories, [id])
    }

    // MARK: - Helpers

    private class HackrStoryCacheSpy: HackrStoryCache {
        func save(_: Story, completion _: @escaping (HackrStoryCache.SaveResult) -> Void) {}
    }
}
