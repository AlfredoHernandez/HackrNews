//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class RealmHackrNewsStoryStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyStoryOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .success(.none))
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .success(.none))
        expect(sut, toRetrieve: .success(.none))
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> RealmHackrNewsStoryStore {
        let sut = RealmHackrNewsStoryStore()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(
        _ sut: RealmHackrNewsStoryStore,
        toRetrieve expectedResult: RealmHackrNewsStoryStore.RetrievalResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for retrieve command")
        sut.retrieve(storyID: anyID()) { retrievedResult in
            switch (retrievedResult, expectedResult) {
            case (.success(.none), .success(.none)):
                break
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
