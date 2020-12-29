//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class LocalLiveHackrNewsLoader {
    let store: LiveHackrNewsStore
    let currentDate: () -> Date

    init(store: LiveHackrNewsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    func save(_ news: [LiveHackrNew]) {
        store.deleteCachedNews { [unowned self] error in
            guard error == nil else { return }
            self.store.insertCacheNews(news, with: self.currentDate())
        }
    }
}

class LiveHackrNewsStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCacheStoriesCallCount = 0
    var deletionRequests = [DeletionCompletion]()
    var insertions = [(news: [LiveHackrNew], timestamp: Date)]()

    func deleteCachedNews(completion: @escaping DeletionCompletion) {
        deleteCacheStoriesCallCount += 1
        deletionRequests.append(completion)
    }

    func insertCacheNews(_ news: [LiveHackrNew], with timestamp: Date) {
        insertions.append((news, timestamp))
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionRequests[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionRequests[index](.none)
    }
}

final class CacheHackrNewsUseCase: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deleteCacheStoriesCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let liveHackrNews = anyLiveHackrNews()

        sut.save(liveHackrNews)

        XCTAssertEqual(store.deleteCacheStoriesCallCount, 1)
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let liveHackrNews = anyLiveHackrNews()

        sut.save(liveHackrNews)
        store.completeDeletion(with: anyNSError())

        XCTAssertEqual(store.insertions.count, 0)
    }

    func test_save_requestsCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        let liveHackrNews = anyLiveHackrNews()

        sut.save(liveHackrNews)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.news, liveHackrNews)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
    }

    // MARK: - Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: LocalLiveHackrNewsLoader, store: LiveHackrNewsStore) {
        let store = LiveHackrNewsStore()
        let sut = LocalLiveHackrNewsLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func anyLiveHackrNews() -> [LiveHackrNew] {
        [LiveHackrNew(id: 1), LiveHackrNew(id: 2), LiveHackrNew(id: 3)]
    }
}
