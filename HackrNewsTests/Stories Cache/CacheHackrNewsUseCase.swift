//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class LocalLiveHackrNewsLoader {
    init(store _: LiveHackrNewsStore) {}
}

class LiveHackrNewsStore {
    var deleteCacheStoriesCallCount = 0
}

final class CacheHackrNewsUseCase: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = LiveHackrNewsStore()

        _ = LocalLiveHackrNewsLoader(store: store)

        XCTAssertEqual(store.deleteCacheStoriesCallCount, 0)
    }
}
