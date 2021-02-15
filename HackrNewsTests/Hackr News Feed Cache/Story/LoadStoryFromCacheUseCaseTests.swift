//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LoadStoryFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotLoadCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestsCacheRetrieval() {
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

    func test_load_retrievesStoryNotFoundErrorOnNonStoryCached() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failure(.storyNotFound), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }

    func test_load_deliversCachedStoryOnNonExpiredCache() {
        let (sut, store) = makeSUT()
        let story = Story.uniqueStory()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusStoryCacheMaxAge().adding(seconds: 1)

        expect(sut, toCompleteWith: .success(story.model), when: {
            store.completeRetrieval(with: story.local, timestamp: nonExpiredTimestamp)
        })
    }

    // MARK: - Helpers

    private func makeSUT(
        timestamp: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (LocalHackrStoryLoader, HackrNewsStoryStoreSpy) {
        let store = HackrNewsStoryStoreSpy()
        let sut = LocalHackrStoryLoader(store: store, timestamp: timestamp)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func failure(_ error: LocalHackrStoryLoader.Error) -> LocalHackrStoryLoader.LoadResult {
        .failure(error)
    }

    private func expect(
        _ sut: LocalHackrStoryLoader,
        toCompleteWith expectedResult: LocalHackrStoryLoader.LoadResult,
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
}
