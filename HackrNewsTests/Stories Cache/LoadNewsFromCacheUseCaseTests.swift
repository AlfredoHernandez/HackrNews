//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
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

    func test_load_deliversCachedNewsOnLessThanOneDayOldCache() {
        let news = anyLiveHackrNews()
        let fixedCurrentDate = Date()
        let lessThanOneDayOldTimestamp = fixedCurrentDate.adding(days: -1).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(news.models)) {
            store.completeRetrieval(with: news.local, timestamp: lessThanOneDayOldTimestamp)
        }
    }

    func test_load_deliversNoNewsOnMoreThanOneDayOldCache() {
        let news = anyLiveHackrNews()
        let fixedCurrentDate = Date()
        let moreThanOneDayOldTimestamp = fixedCurrentDate.adding(days: -1).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: news.local, timestamp: moreThanOneDayOldTimestamp)
        }
    }

    func test_load_deliversNoNewsOnOneDayOldCache() {
        let news = anyLiveHackrNews()
        let fixedCurrentDate = Date()
        let oneDayOldTimestamp = fixedCurrentDate.adding(days: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: news.local, timestamp: oneDayOldTimestamp)
        }
    }

    // MARK: - Cache deletion business case

    func test_load_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_load_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_doesNotDeleteCacheOnLessThatOneDayOldCache() {
        let news = anyLiveHackrNews()
        let fixedCurrentDate = Date()
        let lessThanOneDayOldTimestamp = fixedCurrentDate.adding(days: -1).adding(seconds: 1)
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: news.local, timestamp: lessThanOneDayOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_deletesCacheOnOneDayOldCache() {
        let news = anyLiveHackrNews()
        let fixedCurrentDate = Date()
        let oneDayOldTimestamp = fixedCurrentDate.adding(days: -1)
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: news.local, timestamp: oneDayOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_load_deletesCacheOnMoreThanOneDayOldCache() {
        let news = anyLiveHackrNews()
        let fixedCurrentDate = Date()
        let moreThanOneDayOldTimestamp = fixedCurrentDate.adding(days: -1).adding(days: -1)
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: news.local, timestamp: moreThanOneDayOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deletion])
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = LiveHackrNewsStoreSpy()
        var sut: LocalLiveHackrNewsLoader? = LocalLiveHackrNewsLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalLiveHackrNewsLoader.LoadResult]()

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
    ) -> (sut: LocalLiveHackrNewsLoader, store: LiveHackrNewsStoreSpy) {
        let store = LiveHackrNewsStoreSpy()
        let sut = LocalLiveHackrNewsLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func expect(
        _ sut: LocalLiveHackrNewsLoader,
        toCompleteWith expectedResult: LocalLiveHackrNewsLoader.LoadResult,
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

    private func anyLiveHackrNews() -> (models: [LiveHackrNew], local: [LocalLiveHackrNew]) {
        let models = [LiveHackrNew(id: 1), LiveHackrNew(id: 2), LiveHackrNew(id: 3)]
        let locals = models.map { LocalLiveHackrNew(id: $0.id) }
        return (models, locals)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
