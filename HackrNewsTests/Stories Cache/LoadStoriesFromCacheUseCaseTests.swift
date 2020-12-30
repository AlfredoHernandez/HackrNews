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

    private class LiveHackrNewsStoreSpy: LiveHackrNewsStore {
        private(set) var deletionRequests = [DeletionCompletion]()
        private(set) var insertionRequests = [InsertionCompletion]()
        private(set) var receivedMessages = [ReceivedMessage]()

        enum ReceivedMessage: Equatable {
            case deletion
            case insertion([LocalLiveHackrNew], Date)
        }

        func deleteCachedNews(completion: @escaping DeletionCompletion) {
            deletionRequests.append(completion)
            receivedMessages.append(.deletion)
        }

        func insertCacheNews(_ news: [LocalLiveHackrNew], with timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionRequests.append(completion)
            receivedMessages.append(.insertion(news, timestamp))
        }

        func completeDeletion(with error: Error, at index: Int = 0) {
            deletionRequests[index](error)
        }

        func completeDeletionSuccessfully(at index: Int = 0) {
            deletionRequests[index](.none)
        }

        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionRequests[index](error)
        }

        func completeInsertionSuccessfully(at index: Int = 0) {
            insertionRequests[index](.none)
        }
    }
}
