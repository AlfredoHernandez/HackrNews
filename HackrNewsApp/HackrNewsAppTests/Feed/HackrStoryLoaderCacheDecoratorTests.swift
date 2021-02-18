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
        let (_, loader, _) = makeSUT()

        XCTAssertEqual(loader.loadedStories, [], "Expected to not load a story")
    }

    func test_load_loadsFromLoader() {
        let (sut, loader, _) = makeSUT()
        let id = anyID()

        _ = sut.load(id: id) { _ in }

        XCTAssertEqual(loader.loadedStories, [id])
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (HackrStoryLoaderCacheDecorator, HackrStoryLoaderSpy, HackrStoryCacheSpy) {
        let loader = HackrStoryLoaderSpy()
        let cache = HackrStoryCacheSpy()
        let sut = HackrStoryLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(cache, file: file, line: line)
        return (sut, loader, cache)
    }

    private class HackrStoryCacheSpy: HackrStoryCache {
        func save(_: Story, completion _: @escaping (HackrStoryCache.SaveResult) -> Void) {}
    }
}
