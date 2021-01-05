//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class CodableHackrNewsStore {
    private struct Cache: Codable {
        let news: [LocalLiveHackrNew]
        let timestamp: Date
    }

    private let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent("news.store")

    func retrieve(completion: @escaping LiveHackrNewsStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let decoded = try! decoder.decode(Cache.self, from: data)
        completion(.found(news: decoded.news, timestamp: decoded.timestamp))
    }

    func insertCacheNews(_ news: [LocalLiveHackrNew], with timestamp: Date, completion: @escaping LiveHackrNewsStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(news: news, timestamp: timestamp))
        try! encoded.write(to: storeUrl)
        completion(nil)
    }
}

final class CodableHackrNewsStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("news.store")
        try? FileManager.default.removeItem(at: storeUrl)
    }

    override func tearDown() {
        super.tearDown()
        let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("news.store")
        try? FileManager.default.removeItem(at: storeUrl)
    }

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

    func test_retrieve_hasNoSideEffects() {
        let sut = CodableHackrNewsStore()
        let exp = expectation(description: "Wait for result")

        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail(
                        "Expected retrieving twice from empty cache to deliver same empty result, but got \(firstResult)m \(secondResult) instead."
                    )
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = CodableHackrNewsStore()
        let exp = expectation(description: "Wait for result")
        let news = [LocalLiveHackrNew(id: 1), LocalLiveHackrNew(id: 2), LocalLiveHackrNew(id: 3)]
        let timestap = Date()

        sut.insertCacheNews(news, with: timestap) { insertionError in
            XCTAssertNil(insertionError, "Expected news to be inserted successfully")
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(news: retrievedNews, timestamp: retrievedTimestamp):
                    XCTAssertEqual(retrievedNews, news)
                    XCTAssertEqual(retrievedTimestamp, timestap)
                default:
                    XCTFail("Expected found result with \(news) and \(timestap), but got \(retrieveResult) instead.")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }
}
