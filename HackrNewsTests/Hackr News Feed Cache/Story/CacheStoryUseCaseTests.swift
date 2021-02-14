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
    private let timestamp: () -> Date

    init(store: HackrStoryStoreSpy, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }

    func save(_ story: Story, completion: @escaping (SaveResult) -> Void) {
        store.delete(story) { [unowned self] deletionResult in
            switch deletionResult {
            case .success:
                store.insert(story: story, with: self.timestamp())
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

class HackrStoryStoreSpy {
    typealias DeletionResult = Swift.Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    enum Message: Equatable {
        case deletion(Story)
        case insertion(Story, Date)
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

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }

    func insert(story: Story, with timestamp: Date) {
        receivedMessages.append(.insertion(story, timestamp))
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

        sut.save(story) { _ in }
        store.completeDeletion(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.deletion(story)])
    }

    func test_save_requestsCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(timestamp: { timestamp })
        let story = Story.any

        sut.save(story) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deletion(story), .insertion(story, timestamp)])
    }

    // MARK: - Helpers

    private func makeSUT(
        timestamp: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (LocalHackrStoryLoader, HackrStoryStoreSpy) {
        let store = HackrStoryStoreSpy()
        let sut = LocalHackrStoryLoader(store: store, timestamp: timestamp)
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
