//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class CodableHackrNewsStore {
    func retrieve(completion: @escaping LiveHackrNewsStore.RetrievalCompletion) {
        completion(.empty)
    }
}

final class CodableHackrNewsStoreTests: XCTestCase {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableHackrNewsStore()
        let exp = expectation(description: "Wait for result")

        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead.")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
