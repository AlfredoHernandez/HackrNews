//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class CacheHackrNewsUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()

        sut.save(uniqueHackrNews().models) { _ in }

        XCTAssertEqual(store.receivedMessages, [.deletion])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()

        sut.save(uniqueHackrNews().models) { _ in }
        store.completeDeletion(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.deletion])
    }

    func test_save_requestsCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let hackrNews = uniqueHackrNews()

        sut.save(hackrNews.models) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deletion, .insertion(hackrNews.local, timestamp)])
    }

    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
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

    func test_save_doesNotDeliversDelitionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = HackrNewsFeedStoreSpy()
        var sut: LocalHackrNewsFeedLoader? = LocalHackrNewsFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalHackrNewsFeedLoader.SaveResult]()

        sut?.save(uniqueHackrNews().models, completion: { result in
            receivedResults.append(result)
        })
        sut = nil

        store.completeDeletion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty, "Expected to have no results, but got \(receivedResults)")
    }

    func test_save_doesNotDeliversInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = HackrNewsFeedStoreSpy()
        var sut: LocalHackrNewsFeedLoader? = LocalHackrNewsFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalHackrNewsFeedLoader.SaveResult]()

        sut?.save(uniqueHackrNews().models, completion: { result in
            receivedResults.append(result)
        })
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty, "Expected to have no results, but got \(receivedResults)")
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

    private func uniqueHackrNews() -> (models: [HackrNew], local: [LocalHackrNew]) {
        let models = [HackrNew(id: 1), HackrNew(id: 2), HackrNew(id: 3)]
        let locals = models.map { LocalHackrNew(id: $0.id) }
        return (models, locals)
    }

    private func expect(
        _ sut: LocalHackrNewsFeedLoader,
        toCompleteWithError expectedError: NSError?,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var receivedError: Error?
        let exp = expectation(description: "Wait for save command")

        sut.save(uniqueHackrNews().models) { result in
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
