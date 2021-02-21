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
        let id = anyID

        _ = sut.load(id: id) { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve(storyID: id)])
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

    func test_load_deliversStoryOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let story = Story.unique()
        let nonExpiredTimestamp = fixedCurrentDate.minusStoryCacheMaxAge().adding(seconds: 1)

        expect(sut, toCompleteWith: .success(story.model), when: {
            store.completeRetrieval(with: story.local, timestamp: nonExpiredTimestamp)
        })
    }

    func test_load_deliversNoStoryOnCacheExpiration() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let story = Story.unique()
        let expirationTimestamp = fixedCurrentDate.minusStoryCacheMaxAge()

        expect(sut, toCompleteWith: failure(.expiredCache), when: {
            store.completeRetrieval(with: story.local, timestamp: expirationTimestamp)
        })
    }

    func test_load_deliversNoStoryOnExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let story = Story.unique()
        let expiredTimestamp = fixedCurrentDate.minusStoryCacheMaxAge().adding(seconds: -1)

        expect(sut, toCompleteWith: failure(.expiredCache), when: {
            store.completeRetrieval(with: story.local, timestamp: expiredTimestamp)
        })
    }

    func test_load_doesNotDeliverResultAfterCancellingTask() {
        let (sut, store) = makeSUT()
        let anyHackrNew = HackrNew(id: 1)
        let story = Story.unique()
        var receivedResults = [LocalHackrStoryLoader.LoadResult]()

        let task = sut.load(id: anyHackrNew.id) { result in
            receivedResults.append(result)
        }
        task.cancel()

        store.completeRetrieval(with: story.local, timestamp: Date())

        XCTAssertTrue(receivedResults.isEmpty, "Expected no results after cancelling task")
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = HackrNewsStoryStoreSpy()
        var sut: LocalHackrStoryLoader? = LocalHackrStoryLoader(store: store, currentDate: Date.init)
        let story = Story.unique()

        var receivedResults = [LocalHackrStoryLoader.LoadResult]()
        _ = sut?.load(id: anyID, completion: { receivedResults.append($0) })

        sut = nil
        store.completeRetrieval(with: story.local, timestamp: Date())
        store.completeRetrieval(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty, "Expected not received results but got \(receivedResults) instead")
    }

    // MARK: - Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (LocalHackrStoryLoader, HackrNewsStoryStoreSpy) {
        let store = HackrNewsStoryStoreSpy()
        let sut = LocalHackrStoryLoader(store: store, currentDate: currentDate)
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

        _ = sut.load(id: anyID) { receivedResult in
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

    private var anyID: Int {
        Int.random(in: 0 ... 100)
    }
}
