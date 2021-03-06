//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class ValidateHackrNewsFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let news = uniqueHackrNews()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_deletesCacheOnCacheExpiration() {
        let news = uniqueHackrNews()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusCacheMaxAge()
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_validateCache_deletesCacheOnExpiredCache() {
        let news = uniqueHackrNews()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusCacheMaxAge().adding(days: -1)
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = HackrNewsFeedStoreSpy()
        var sut: LocalHackrNewsFeedLoader? = LocalHackrNewsFeedLoader(store: store, currentDate: Date.init)

        sut?.validateCache()
        sut = nil
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    // MARK: - Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalHackrNewsFeedLoader, store: HackrNewsFeedStoreSpy) {
        let store = HackrNewsFeedStoreSpy()
        let sut = LocalHackrNewsFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    // MARK: - Shared helpers

    private func uniqueHackrNews() -> (models: [HackrNew], local: [LocalHackrNew]) {
        let models = [HackrNew(id: 1), HackrNew(id: 2), HackrNew(id: 3)]
        let locals = models.map { LocalHackrNew(id: $0.id) }
        return (models, locals)
    }
}
