//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import RealmSwift
import XCTest

final class RealmHackrNewsStoryStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
    }

    func test_retrieve_deliversEmptyStoryOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, withId: anyID(), toRetrieve: .success(.none))
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, withId: anyID(), toRetrieve: .success(.none))
        expect(sut, withId: anyID(), toRetrieve: .success(.none))
    }

    func test_retrieve_deliversNotFoundStoryOnNonEmptyCache() {
        let sut = makeSUT()
        let story = Story.unique()
        let timestamp = Date()

        insert((story.local, timestamp), to: sut)
        expect(sut, withId: story.model.id + 1, toRetrieve: .success(.none))
    }

    func test_retrieve_deliversFoundStoryOnNonEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let story = Story.unique()

        insert((story.local, timestamp), to: sut)
        expect(sut, withId: story.model.id, toRetrieve: .success(CachedStory(story.local, timestamp)))
    }

    func test_retrieve_deliversFoundStoryWithoutAllPropertiesOnNonEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let story = Story(
            id: 1,
            title: nil,
            text: nil,
            author: "an author",
            score: nil,
            createdAt: Date(),
            totalComments: nil,
            comments: nil,
            type: "any",
            url: nil
        )

        insert((story.toLocal(), timestamp), to: sut)
        expect(sut, withId: story.id, toRetrieve: .success(CachedStory(story.toLocal(), timestamp)))
    }

    func test_retrieve_deliversFoundStoryHasNoSideEffects() {
        let sut = makeSUT()
        let timestamp = Date()
        let story = Story.unique()

        insert((story.local, timestamp), to: sut)

        expect(sut, withId: story.model.id, toRetrieve: .success(CachedStory(story.local, timestamp)))
        expect(sut, withId: story.model.id, toRetrieve: .success(CachedStory(story.local, timestamp)))
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let story = Story.unique()

        let insertionError = insert((story.local, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let story = Story.unique()

        insert((Story.unique().local, Date()), to: sut)

        let insertionError = insert((story.local, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }

    func test_insert_deliversNonErrorOnDuplicatedInsertion() {
        let sut = makeSUT()
        let timestamp = Date()
        let story = Story.unique()

        insert((story.local, timestamp), to: sut)

        let insertionError = insert((story.local, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected to update inserted story in cache")

        expect(sut, withId: story.local.id, toRetrieve: .success(CachedStory(story.local, timestamp)))
    }

    func test_delete_deliversNonErrorOnEmptyCache() {
        let sut = makeSUT()

        let receivedError = delete(sut, story: anyID())
        XCTAssertNil(receivedError, "Expected error on not found story (Empty cache)")
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let timestamp = Date()
        let story = Story.unique()

        insert((story.local, timestamp), to: sut)

        let receivedError = delete(sut, story: story.local.id)
        XCTAssertNil(receivedError, "Expected to delete previous inserted story")

        expect(sut, withId: story.local.id, toRetrieve: .success(nil))
    }

    func test_actions_runsSerially() {
        let sut = makeSUT()
        let timestamp = Date()
        let story = Story.unique()

        let op1 = expectation(description: "Operation 1")
        sut.insert(story: story.local, timestamp: timestamp) { _ in op1.fulfill() }

        let op2 = expectation(description: "Operation 2")
        sut.insert(story: story.local, timestamp: timestamp) { _ in op2.fulfill() }

        let op3 = expectation(description: "Operation 3")
        sut.retrieve(storyID: story.local.id) { _ in op3.fulfill() }

        let op4 = expectation(description: "Operation 4")
        sut.delete(storyID: story.local.id) { _ in op4.fulfill() }

        wait(for: [op1, op2, op3, op4], timeout: 3.0, enforceOrder: true)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RealmHackrNewsStoryStore {
        let sut = RealmHackrNewsStoryStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(
        _ sut: RealmHackrNewsStoryStore,
        withId id: Int,
        toRetrieve expectedResult: RealmHackrNewsStoryStore.RetrievalResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for retrieve command")
        sut.retrieve(storyID: id) { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.success(.none), .success(.none)):
                break
            case let (.success(.some(retrievedCache)), .success(.some(expectedCache))):
                XCTAssertEqual(
                    retrievedCache.story,
                    expectedCache.story,
                    "Expected `Story` \(String(describing: expectedCache.story)), got \(String(describing: retrievedCache.story)) instead.",
                    file: file,
                    line: line
                )
                XCTAssertEqual(
                    retrievedCache.timestamp,
                    expectedCache.timestamp,
                    "Expected `Timestamp`\(String(describing: expectedCache.timestamp)), got \(String(describing: retrievedCache.timestamp)) instead.",
                    file: file,
                    line: line
                )
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    @discardableResult
    private func insert(_ cache: (story: LocalStory, timestamp: Date), to sut: RealmHackrNewsStoryStore) -> Error? {
        let exp = expectation(description: "Wait for insertion")
        var insertionError: Error?

        sut.insert(story: cache.story, timestamp: cache.timestamp) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    private func delete(_ sut: RealmHackrNewsStoryStore, story: Int) -> Error? {
        let exp = expectation(description: "Wait for insertion")
        var deletionError: Error?

        sut.delete(storyID: story) { result in
            if case let Result.failure(error) = result { deletionError = error }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
}
