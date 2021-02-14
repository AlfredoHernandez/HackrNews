//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LoadStoryFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotLoadCacheUponCreation() {
        let store = HackrNewsStoryStoreSpy()
        _ = LocalHackrStoryLoader(store: store, timestamp: Date.init)

        XCTAssertEqual(store.receivedMessages, [])
    }
}
