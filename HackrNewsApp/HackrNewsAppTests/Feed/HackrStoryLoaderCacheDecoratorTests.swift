//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import XCTest

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

    func test_cancelLoad_cancelsLoadingTask() {
        let (sut, loader, _) = makeSUT()
        let story = Story.unique().model

        let task = sut.load(id: story.id) { _ in }
        task.cancel()
        loader.completes(with: story)

        XCTAssertEqual(loader.cancelledStories, [story.id], "Expected to cancell story with id \(story.id), got \(loader.cancelledStories) instead")
    }

    func test_load_failsOnLoaderFailure() {
        let (sut, loader, _) = makeSUT()

        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            loader.completes(with: anyNSError())
        })
    }

    func test_load_deliversAStoryOnLoaderSuccess() {
        let (sut, loader, _) = makeSUT()
        let story = Story.unique().model

        expect(sut, toCompleteWith: .success(story), when: {
            loader.completes(with: story)
        })
    }

    func test_load_cachesStoryDataOnLoaderSuccess() {
        let (sut, loader, cache) = makeSUT()
        let story = Story.unique().model

        _ = sut.load(id: story.id, completion: { _ in })
        loader.completes(with: story)

        XCTAssertEqual(cache.cachedStories, [story], "Expected to cache story \(story), got \(cache.cachedStories) instead.")
    }

    func test_load_doesNotCacheStoryDataOnLoaderFailure() {
        let (sut, loader, cache) = makeSUT()
        let story = Story.unique().model

        _ = sut.load(id: story.id, completion: { _ in })
        loader.completes(with: anyNSError())

        XCTAssertEqual(cache.cachedStories, [], "Expected to not cache a story")
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

    private func expect(
        _ sut: HackrStoryLoaderCacheDecorator,
        toCompleteWith expectedResult: HackrStoryLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load")
        _ = sut.load(id: anyID()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedStory), .success(expectedStory)):
                XCTAssertEqual(receivedStory, expectedStory, "Expected \(expectedStory) but got \(receivedStory)", file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, "Expected \(expectedError) but got \(receivedError)", file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }

    private class HackrStoryCacheSpy: HackrStoryCache {
        var completions = [(story: Story, completion: (HackrStoryCache.SaveResult) -> Void)]()
        var cachedStories: [Story] {
            completions.map(\.story)
        }

        func save(_ story: Story, completion: @escaping (HackrStoryCache.SaveResult) -> Void) {
            completions.append((story, completion))
        }
    }
}
