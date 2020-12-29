//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest
import HackrNews

class LocalLiveHackrNewsLoader {
    let store: LiveHackrNewsStore
    
    init(store: LiveHackrNewsStore) {
        self.store = store
    }
    
    func save(_ news: [LiveHackrNew]) {
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
        let store = LiveHackrNewsStore()

        _ = LocalLiveHackrNewsLoader(store: store)

        XCTAssertEqual(store.deleteCacheStoriesCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let store = LiveHackrNewsStore()
        let sut = LocalLiveHackrNewsLoader(store: store)
        let liveHackrNews = [LiveHackrNew(id: 1), LiveHackrNew(id: 2), LiveHackrNew(id: 3)]
        
        sut.save(liveHackrNews)
        
        XCTAssertEqual(store.deleteCacheStoriesCallCount, 1)
    }
}
