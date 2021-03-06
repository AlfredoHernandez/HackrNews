//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LoadNewsFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotLoadCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()

        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }

    func test_load_retrieveNoNewsOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }

    func test_load_deliversCachedNewsOnNonExpiredCache() {
        let news = uniqueHackrNews()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(news.models)) {
            store.completeRetrieval(with: news.local, timestamp: nonExpiredTimestamp)
        }
    }

    func test_load_deliversNoNewsOnExpiredCache() {
        let news = uniqueHackrNews()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: news.local, timestamp: expiredTimestamp)
        }
    }

    func test_load_deliversNoNewsOnCacheExpiration() {
        let news = uniqueHackrNews()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: news.local, timestamp: expirationTimestamp)
        }
    }

    // MARK: - Cache deletion business case

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let news = uniqueHackrNews()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: news.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectCacheOnCacheExpiration() {
        let news = uniqueHackrNews()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusCacheMaxAge()
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: news.local, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_hasNoSideEffectsOnExpiredCache() {
        let news = uniqueHackrNews()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusCacheMaxAge().adding(days: -1)
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: news.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = HackrNewsFeedStoreSpy()
        var sut: LocalHackrNewsFeedLoader? = LocalHackrNewsFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalHackrNewsFeedLoader.LoadResult]()

        sut?.load { receivedResults.append($0) }
        sut = nil
        store.completeRetrievalWithEmptyCache()

        XCTAssertTrue(receivedResults.isEmpty)
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

    private func expect(
        _ sut: LocalHackrNewsFeedLoader,
        toCompleteWith expectedResult: LocalHackrNewsFeedLoader.LoadResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedNews), .success(expectedNews)):
                XCTAssertEqual(receivedNews, expectedNews, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead")
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Shared helpers

    private func uniqueHackrNews() -> (models: [HackrNew], local: [LocalHackrNew]) {
        let models = [HackrNew(id: 1), HackrNew(id: 2), HackrNew(id: 3)]
        let locals = models.map { LocalHackrNew(id: $0.id) }
        return (models, locals)
    }
}
