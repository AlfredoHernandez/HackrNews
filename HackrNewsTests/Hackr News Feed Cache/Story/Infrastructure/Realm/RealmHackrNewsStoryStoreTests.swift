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

    func test_retrieve_deliversFoundStoryOnNonEmptyCache() {
        let sut = makeSUT()
        let story = Story.any

        insert(sut, story: story.toLocal())
        expect(sut, withId: story.id, toRetrieve: .success(story.toLocal()))
    }

    func test_retrieve_deliversFoundStoryWithoutAllPropertiesOnNonEmptyCache() {
        let sut = makeSUT()
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

        insert(sut, story: story.toLocal())
        expect(sut, withId: story.id, toRetrieve: .success(story.toLocal()))
    }

    func test_retrieve_deliversFoundStoryHasNoSideEffects() {
        let sut = makeSUT()
        let story = Story.any

        insert(sut, story: story.toLocal())

        expect(sut, withId: story.id, toRetrieve: .success(story.toLocal()))
        expect(sut, withId: story.id, toRetrieve: .success(story.toLocal()))
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
            case let (.success(retrievedStory), .success(expectedStory)):
                XCTAssertEqual(
                    retrievedStory,
                    expectedStory,
                    "Expected \(String(describing: expectedStory)), got \(String(describing: retrievedStory)) instead.",
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
    private func insert(_ sut: RealmHackrNewsStoryStore, story: LocalStory) -> Error? {
        let exp = expectation(description: "Wait for insertion")
        var insertionError: Error?

        sut.insert(story: story) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
}
