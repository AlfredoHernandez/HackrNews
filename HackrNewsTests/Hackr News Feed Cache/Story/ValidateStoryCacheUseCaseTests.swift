//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class ValidateStoryCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        let id = anyID()

        sut.validate(cacheforStory: id) { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve(storyID: id), .deletion(storyID: id)])
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        let id = anyID()

        sut.validate(cacheforStory: id) { _ in }
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve(storyID: id)])
    }

    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let story = Story.unique()
        let nonExpiredTimestamp = fixedCurrentDate.minusStoryCacheMaxAge().adding(seconds: 1)

        sut.validate(cacheforStory: story.model.id) { _ in }
        store.completeRetrieval(with: story.local, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve(storyID: story.model.id)])
    }

    func test_validateCache_deletesCacheOnExpiration() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let story = Story.unique()
        let expirationTimestamp = fixedCurrentDate.minusStoryCacheMaxAge()

        sut.validate(cacheforStory: story.model.id) { _ in }
        store.completeRetrieval(with: story.local, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve(storyID: story.model.id), .deletion(storyID: story.model.id)])
    }

    func test_validateCache_deletesExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let story = Story.unique()
        let expiredTimestamp = fixedCurrentDate.minusStoryCacheMaxAge().adding(seconds: -1)

        sut.validate(cacheforStory: story.model.id) { _ in }
        store.completeRetrieval(with: story.local, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve(storyID: story.model.id), .deletion(storyID: story.model.id)])
    }

    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletion(with: deletionError)
        })
    }

    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletionSuccessfully()
        })
    }

    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }

    func test_validateCache_succeedsOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let story = Story.unique()
        let nonExpiredTimestamp = fixedCurrentDate.minusStoryCacheMaxAge().adding(seconds: 1)

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: story.local, timestamp: nonExpiredTimestamp)
        })
    }

    func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let story = Story.unique()
        let expiredTimestamp = fixedCurrentDate.minusStoryCacheMaxAge().adding(seconds: -1)
        let deletionError = anyNSError()

        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrieval(with: story.local, timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        })
    }

    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let story = Story.unique()
        let expiredTimestamp = fixedCurrentDate.minusStoryCacheMaxAge().adding(seconds: -1)

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieval(with: story.local, timestamp: expiredTimestamp)
            store.completeDeletionSuccessfully()
        })
    }

    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = HackrNewsStoryStoreSpy()
        var sut: LocalHackrStoryLoader? = LocalHackrStoryLoader(store: store, currentDate: Date.init)
        let id = anyID()

        sut?.validate(cacheforStory: id) { _ in }
        sut = nil
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve(storyID: id)])
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

    private func expect(
        _ sut: LocalHackrStoryLoader,
        toCompleteWith expectedResult: LocalHackrStoryLoader.ValidationResult,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        sut.validate(cacheforStory: anyID()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}
