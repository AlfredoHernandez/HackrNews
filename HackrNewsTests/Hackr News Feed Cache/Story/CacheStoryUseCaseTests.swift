//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class CacheStoryUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let story = Story.uniqueStory()

        sut.save(story.model) { _ in }

        XCTAssertEqual(store.receivedMessages, [.deletion(story.local)], "Expected to delete \(story)")
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let story = Story.uniqueStory()

        sut.save(story.model) { _ in }
        store.completeDeletion(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.deletion(story.local)])
    }

    func test_save_requestsCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        let story = Story.uniqueStory()

        sut.save(story.model) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deletion(story.local), .insertion(story.local)])
    }

    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: anyNSError()) {
            store.completeDeletion(with: anyNSError())
        }
    }

    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }

    func test_save_succeedsOnSuccessfulInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: .none, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }

    func test_save_doesNotDeliversDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = HackrNewsStoryStoreSpy()
        var sut: LocalHackrStoryLoader? = LocalHackrStoryLoader(store: store)
        var receivedResults = [LocalHackrStoryLoader.SaveResult]()

        sut?.save(Story.any) { receivedResults.append($0) }
        sut = nil
        store.completeDeletion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
    }

    func test_save_doesNotDeliversInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = HackrNewsStoryStoreSpy()
        var sut: LocalHackrStoryLoader? = LocalHackrStoryLoader(store: store)
        var receivedResults = [LocalHackrStoryLoader.SaveResult]()

        sut?.save(Story.any) { receivedResults.append($0) }
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (LocalHackrStoryLoader, HackrNewsStoryStoreSpy) {
        let store = HackrNewsStoryStoreSpy()
        let sut = LocalHackrStoryLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func expect(
        _ sut: LocalHackrStoryLoader,
        toCompleteWithError expectedError: NSError?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var receivedError: Error?
        let exp = expectation(description: "Wait for save command")

        sut.save(Story.any) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                receivedError = error
            }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
}
