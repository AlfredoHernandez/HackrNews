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

        let exp = expectation(description: "Wait for insertion")
        sut.insert(story: story.toLocal()) { result in
            switch result {
            case .success:
                break
            case let .failure(error):
                XCTFail("Expected to insert given values, but got \(error) instead.")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
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
}
