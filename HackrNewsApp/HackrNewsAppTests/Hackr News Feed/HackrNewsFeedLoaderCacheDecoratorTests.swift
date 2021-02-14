//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

protocol HackrNewsFeedCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ news: [HackrNew], completion: @escaping (SaveResult) -> Void)
}

class HackrNewsFeedLoaderCacheDecorator: HackrNewsFeedLoader {
    private let decoratee: HackrNewsFeedLoader
    private let cache: HackrNewsFeedCache

    init(decoratee: HackrNewsFeedLoader, cache: HackrNewsFeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    func load(completion: @escaping (HackrNewsFeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.cache.save(feed) { _ in }
                completion(.success(feed))
            default:
                completion(result)
            }
        }
    }
}

final class HackrNewsFeedLoaderCacheDecoratorTests: XCTestCase {
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))

        expect(sut, toCompleteWith: .success(feed))
    }

    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))

        expect(sut, toCompleteWith: .failure(anyNSError()))
    }

    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let cache = CacheSpy()
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)

        sut.load { _ in }

        XCTAssertEqual(cache.messages, [.save(feed)], "Expected to cache loaded feed on success")
    }

    func test_load_doesNotCacheOnLoaderFailure() {
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cache)

        sut.load { _ in }

        XCTAssertTrue(cache.messages.isEmpty, "Expected not to cache feed on load error")
    }

    // MARK: - Helpers

    private func makeSUT(
        loaderResult: HackrNewsFeedLoader.Result,
        cache: CacheSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> HackrNewsFeedLoader {
        let loader = FeedLoaderStub(loaderResult)
        let sut = HackrNewsFeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private class FeedLoaderStub: HackrNewsFeedLoader {
        private let result: HackrNewsFeedLoader.Result

        init(_ result: HackrNewsFeedLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (HackrNewsFeedLoader.Result) -> Void) {
            completion(result)
        }
    }

    private class CacheSpy: HackrNewsFeedCache {
        enum Message: Equatable {
            case save([HackrNew])
        }

        private(set) var messages = [Message]()

        func save(_ news: [HackrNew], completion _: @escaping (SaveResult) -> Void) {
            messages.append(.save(news))
        }
    }

    func expect(
        _ sut: HackrNewsFeedLoader,
        toCompleteWith expectedResult: HackrNewsFeedLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func uniqueFeed() -> [HackrNew] {
        [HackrNew(id: Int.random(in: 0 ... 100)), HackrNew(id: Int.random(in: 0 ... 100)), HackrNew(id: Int.random(in: 0 ... 100))]
    }
}
