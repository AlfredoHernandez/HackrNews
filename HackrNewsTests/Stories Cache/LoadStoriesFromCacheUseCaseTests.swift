//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LoadStoriesFromCacheUseCaseTests: XCTestCase {
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
        var receivedError: Error?
        let exp = expectation(description: "Wait for load completion")

        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, but got \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(
            receivedError as NSError?,
            retrievalError,
            "Expected a retrieval error, but got \(String(describing: receivedError))"
        )
    }

    func test_load_retrieveNoNewsOnEmptyCache() {
        let (sut, store) = makeSUT()
        var receivedNews = [LiveHackrNew]()
        let exp = expectation(description: "Wait for load completion")

        sut.load { result in
            switch result {
            case let .success(news):
                receivedNews = news
            default:
                XCTFail("Expected success, but got \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrievalWithEmptyCache()

        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(receivedNews.isEmpty)
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
}
