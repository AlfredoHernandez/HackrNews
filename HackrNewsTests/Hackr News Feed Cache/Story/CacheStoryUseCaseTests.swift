//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

protocol HackrStoryCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ story: Story, completion: @escaping (SaveResult) -> Void)
}

class LocalHackrStoryLoader: HackrStoryCache {
    private let store: HackrStoryStoreSpy

    init(store: HackrStoryStoreSpy) {
        self.store = store
    }

    func save(_ story: Story, completion: @escaping (SaveResult) -> Void) {
        store.delete(story) { deletionResult in
            switch deletionResult {
            case let .failure(error):
                completion(.failure(error))
            default:
                break
            }
        }
    }
}

class HackrStoryStoreSpy {
    typealias DeletionResult = Swift.Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    enum Message: Equatable {
        case deletion(Story)
    }

    private(set) var receivedMessages = [Message]()
    private(set) var deletionCompletions = [DeletionCompletion]()

    func delete(_ story: Story, completion: @escaping (DeletionResult) -> Void) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deletion(story))
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
}

class CacheStoryUseCaseTests: XCTestCase {
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let story = Story.any

        sut.save(story) { _ in }

        XCTAssertEqual(store.receivedMessages, [.deletion(story)], "Expected to delete \(story)")
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let story = Story.any
        let exp = expectation(description: "Wait for cache deletion")

        sut.save(story) { _ in
            exp.fulfill()
        }
        store.completeDeletion(with: anyNSError())

        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(store.receivedMessages, [.deletion(story)])
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

extension Story {
    static var any = Story(
        id: Int.random(in: 0 ... 100),
        title: "a title",
        text: "a text",
        author: "a username",
        score: 0,
        createdAt: Date(),
        totalComments: 0,
        comments: [],
        type: "story",
        url: URL(string: "https://any-url.com")!
    )
}
