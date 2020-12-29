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

    func save(_: [LiveHackrNew]) {
        store.deleteCachedNews()
    }
}

class LiveHackrNewsStore {
    var deleteCacheStoriesCallCount = 0

    func deleteCachedNews() {
        deleteCacheStoriesCallCount += 1
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

    // MARK: - Helpers

    private func makeSUT() -> (sut: LocalLiveHackrNewsLoader, store: LiveHackrNewsStore) {
        let store = LiveHackrNewsStore()
        let sut = LocalLiveHackrNewsLoader(store: store)
        return (sut, store)
    }
}
