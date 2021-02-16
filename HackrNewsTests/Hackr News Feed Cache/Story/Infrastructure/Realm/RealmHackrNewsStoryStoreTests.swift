//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class RealmHackrNewsStoryStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyStoryOnEmptyCache() {
        let sut = RealmHackrNewsStoryStore()
        let exp = expectation(description: "Wait for retrieve command")

        sut.retrieve(storyID: anyID()) { retrievedResult in
            switch retrievedResult {
            case .success(.none):
                break
            default:
                XCTFail("Expected to retrieve success, got \(retrievedResult) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
