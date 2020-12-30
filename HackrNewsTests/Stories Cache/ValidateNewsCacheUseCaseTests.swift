//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class ValidateNewsCacheUseCaseTests: XCTestCase {
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

    func test_validateCache_doesNotDeleteCacheOnLessThatOneDayOldCache() {
        let news = anyLiveHackrNews()
        let fixedCurrentDate = Date()
        let lessThanOneDayOldTimestamp = fixedCurrentDate.adding(days: -1).adding(seconds: 1)
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: lessThanOneDayOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validateCache_deletesCacheOnOneDayOldCache() {
        let news = anyLiveHackrNews()
        let fixedCurrentDate = Date()
        let oneDayOldTimestamp = fixedCurrentDate.adding(days: -1)
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: oneDayOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_validateCache_deletesCacheOnMoreThanOneDayOldCache() {
        let news = anyLiveHackrNews()
        let fixedCurrentDate = Date()
        let moreThanOneDayOldTimestamp = fixedCurrentDate.adding(days: -1).adding(days: -1)
        let (sut, store) = makeSUT()

        sut.validateCache()
        store.completeRetrieval(with: news.local, timestamp: moreThanOneDayOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = LiveHackrNewsStoreSpy()
        var sut: LocalLiveHackrNewsLoader? = LocalLiveHackrNewsLoader(store: store, currentDate: Date.init)

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
    ) -> (sut: LocalLiveHackrNewsLoader, store: LiveHackrNewsStoreSpy) {
        let store = LiveHackrNewsStoreSpy()
        let sut = LocalLiveHackrNewsLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    // MARK: - Shared helpers

    private func anyLiveHackrNews() -> (models: [LiveHackrNew], local: [LocalLiveHackrNew]) {
        let models = [LiveHackrNew(id: 1), LiveHackrNew(id: 2), LiveHackrNew(id: 3)]
        let locals = models.map { LocalLiveHackrNew(id: $0.id) }
        return (models, locals)
    }
}

// MARK: - Shared extensions

private extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
