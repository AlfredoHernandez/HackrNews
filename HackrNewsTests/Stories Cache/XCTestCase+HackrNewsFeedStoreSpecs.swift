//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

extension HackrNewsFeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(
        cache: (feed: [LocalHackrNew], timestamp: Date),
        to sut: HackrNewsFeedStore,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var error: Error?

        sut.insertCacheNews(cache.feed, with: cache.timestamp) { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return error
    }

    @discardableResult
    func deleteCache(from sut: HackrNewsFeedStore) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "Wait for deletion completion")

        sut.deleteCachedNews { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    func expect(
        _ sut: HackrNewsFeedStore,
        retrieves expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
                break
            case let (.found(news: retrievedNews, timestamp: retrievedTimestamp), .found(news: expectedNews, timestamp: expectedTimestamp)):
                XCTAssertEqual(retrievedNews, expectedNews, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail(
                    "Expected \(expectedResult), got \(retrievedResult) instead.",
                    file: file,
                    line: line
                )
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    func expect(
        _ sut: HackrNewsFeedStore,
        retrievesTwice expectedResult: RetrieveCachedFeedResult,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) {
        expect(sut, retrieves: expectedResult)
        expect(sut, retrieves: expectedResult)
    }
}
