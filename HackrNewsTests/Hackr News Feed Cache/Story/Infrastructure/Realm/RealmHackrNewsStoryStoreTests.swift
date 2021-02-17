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

        insert(sut, story: story.local)
        expect(sut, withId: story.model.id + 1, toRetrieve: .success(.none))
    }

    func test_retrieve_deliversFoundStoryOnNonEmptyCache() {
        let sut = makeSUT()
        let story = Story.unique()

        insert(sut, story: story.local)
        expect(sut, withId: story.model.id, toRetrieve: .success(story.local))
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
        let story = Story.unique()

        insert(sut, story: story.local)

        expect(sut, withId: story.model.id, toRetrieve: .success(story.local))
        expect(sut, withId: story.model.id, toRetrieve: .success(story.local))
    }

    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        let story = Story.unique()

        let insertionError = insert(sut, story: story.local)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        let story = Story.unique()

        insert(sut, story: Story.unique().local)

        let insertionError = insert(sut, story: story.local)
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
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
