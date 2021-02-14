//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class LocalHackrStoryLoader {
    init(store _: HackrStoryStoreSpy) {}
}

class HackrStoryStoreSpy {
    enum Message: Equatable {
        case deletion
    }

    private(set) var receivedMessages = [Message]()
}

class CacheStoryUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = HackrStoryStoreSpy()
        _ = LocalHackrStoryLoader(store: store)

        XCTAssertEqual(store.receivedMessages, [])
    }
}
