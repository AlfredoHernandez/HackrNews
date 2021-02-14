//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

extension HackrNewsFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, retrieves: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffects(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, retrievesTwice: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(
        on sut: HackrNewsFeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let feed = uniqueFeed()
        let timestamp = Date()

        insert(cache: (feed, timestamp), to: sut, file: file, line: line)
        expect(sut, retrieves: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let feed = uniqueFeed()
        let timestamp = Date()

        insert(cache: (feed, timestamp), to: sut, file: file, line: line)
        expect(sut, retrievesTwice: .success(CachedFeed(feed: feed, timestamp: timestamp)), file: file, line: line)
    }

    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, retrieves: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatRetrievehasNoSideEffectsOnFailure(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, retrievesTwice: .failure(anyNSError()), file: file, line: line)
    }

    func assertThatInsertDeliversErrorOnInsertionError(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert(cache: (feed: uniqueFeed(), timestamp: Date()), to: sut, file: file, line: line)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(cache: (feed: uniqueFeed(), timestamp: Date()), to: sut, file: file, line: line)
        expect(sut, retrieves: .success(.none), file: file, line: line)
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues(
        on sut: HackrNewsFeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        insert(cache: (feed: uniqueFeed(), timestamp: Date()), to: sut, file: file, line: line)

        let latestFeed = [LocalHackrNew(id: 4), LocalHackrNew(id: 5), LocalHackrNew(id: 6)]
        let latestTimestamp = Date()

        insert(cache: (latestFeed, latestTimestamp), to: sut, file: file, line: line)
        expect(sut, retrieves: .success(CachedFeed(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut, file: file, line: line)
        expect(sut, retrieves: .success(.none), file: file, line: line)
    }

    func assertThatDeleteEmptiesPreviousInsertedCache(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert(cache: (feed: uniqueFeed(), timestamp: Date()), to: sut, file: file, line: line)
        deleteCache(from: sut, file: file, line: line)

        expect(sut, retrieves: .success(.none), file: file, line: line)
    }

    func assertThatDeleteDeliversErrorOnDeletionError(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let deletionError = deleteCache(from: sut, file: file, line: line)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }

    func assertThatDeletehasNoSideEffectsOnDeletionError(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        deleteCache(from: sut, file: file, line: line)
        expect(sut, retrieves: .success(.none), file: file, line: line)
    }

    func assertThatStoreSideEffectsRunsSerially(on sut: HackrNewsFeedStore, file: StaticString = #filePath, line: UInt = #line) {
        var completedOperationsInOrder = [XCTestExpectation]()

        let exp1 = expectation(description: "Operation 1")
        sut.insertCacheNews(uniqueFeed(), with: Date()) { _ in
            completedOperationsInOrder.append(exp1)
            exp1.fulfill()
        }

        let exp2 = expectation(description: "Operation 2")
        sut.deleteCachedNews { _ in
            completedOperationsInOrder.append(exp2)
            exp2.fulfill()
        }

        let exp3 = expectation(description: "Operation 3")
        sut.insertCacheNews(uniqueFeed(), with: Date()) { _ in
            completedOperationsInOrder.append(exp3)
            exp3.fulfill()
        }

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(
            completedOperationsInOrder,
            [exp1, exp2, exp3],
            "Expected side-effects to run serially but operation finished in wrong order",
            file: file,
            line: line
        )
    }

    @discardableResult
    func insert(
        cache: (feed: [LocalHackrNew], timestamp: Date),
        to sut: HackrNewsFeedStore,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?

        sut.insertCacheNews(cache.feed, with: cache.timestamp) { insertionResult in
            switch insertionResult {
            case .success:
                break
            case let .failure(error):
                insertionError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return insertionError
    }

    @discardableResult
    func deleteCache(from sut: HackrNewsFeedStore, file _: StaticString = #filePath, line _: UInt = #line) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "Wait for deletion completion")

        sut.deleteCachedNews { deletionResult in
            switch deletionResult {
            case .success:
                break
            case let .failure(error):
                deletionError = error
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    func expect(
        _ sut: HackrNewsFeedStore,
        retrieves expectedResult: HackrNewsFeedStore.RetrievalResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)):
                break
            case let (
                .success(.some(retrievedCache)),
                .success(.some(expectedCache))
            ):
                XCTAssertEqual(retrievedCache.feed, expectedCache.feed, file: file, line: line)
                XCTAssertEqual(retrievedCache.timestamp, expectedCache.timestamp, file: file, line: line)
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
        retrievesTwice expectedResult: HackrNewsFeedStore.RetrievalResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut, retrieves: expectedResult, file: file, line: line)
        expect(sut, retrieves: expectedResult, file: file, line: line)
    }
}
