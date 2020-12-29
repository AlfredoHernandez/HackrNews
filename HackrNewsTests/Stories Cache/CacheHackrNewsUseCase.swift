//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class LocalLiveHackrNewsLoader {
    let store: LiveHackrNewsStore

    init(store: LiveHackrNewsStore) {
        self.store = store
    }

    func save(_ news: [LiveHackrNew]) {
        store.deleteCachedNews { [weak self] error in
            guard error == nil else { return }
            self?.store.insertCacheNews(news)
        }
    }
}

class LiveHackrNewsStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCacheStoriesCallCount = 0
    var insertCacheStoriesCallCount = 0
    var deletionRequests = [DeletionCompletion]()

    func deleteCachedNews(completion: @escaping DeletionCompletion) {
        deleteCacheStoriesCallCount += 1
        deletionRequests.append(completion)
    }

    func insertCacheNews(_: [LiveHackrNew]) {
        insertCacheStoriesCallCount += 1
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
        let liveHackrNews = [LiveHackrNew(id: 1), LiveHackrNew(id: 2), LiveHackrNew(id: 3)]

        sut.save(liveHackrNews)

        XCTAssertEqual(store.deleteCacheStoriesCallCount, 1)
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let liveHackrNews = [LiveHackrNew(id: 1), LiveHackrNew(id: 2), LiveHackrNew(id: 3)]

        sut.save(liveHackrNews)
        store.completeDeletion(with: anyNSError())

        XCTAssertEqual(store.insertCacheStoriesCallCount, 0)
    }

    func test_save_requestsCacheInsertionOnSuccesfulDeletion() {
        let (sut, store) = makeSUT()
        let liveHackrNews = [LiveHackrNew(id: 1), LiveHackrNew(id: 2), LiveHackrNew(id: 3)]

        sut.save(liveHackrNews)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertCacheStoriesCallCount, 1)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalLiveHackrNewsLoader, store: LiveHackrNewsStore) {
        let store = LiveHackrNewsStore()
        let sut = LocalLiveHackrNewsLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
}
