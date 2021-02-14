//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class LocalHackrStoryLoader {
    private let store: HackrStoryStoreSpy

    init(store: HackrStoryStoreSpy) {
        self.store = store
    }

    func save(_ story: Story) {
        store.delete(story)
    }
}

class HackrStoryStoreSpy {
    enum Message: Equatable {
        case deletion(Story)
    }

    private(set) var receivedMessages = [Message]()

    func delete(_ story: Story) {
        receivedMessages.append(.deletion(story))
    }
}

class CacheStoryUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let story = Story(
            id: 1,
            title: "a story",
            text: "a text",
            author: "an author",
            score: 0,
            createdAt: Date(),
            totalComments: 1,
            comments: [1],
            type: "story",
            url: anyURL()
        )

        sut.save(story)

        XCTAssertEqual(store.receivedMessages, [.deletion(story)], "Expected to delete \(story)")
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (LocalHackrStoryLoader, HackrStoryStoreSpy) {
        let store = HackrStoryStoreSpy()
        let sut = LocalHackrStoryLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }
}
