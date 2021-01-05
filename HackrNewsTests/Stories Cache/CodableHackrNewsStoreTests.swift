//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class CodableHackrNewsStore {
    private struct Cache: Codable {
        let news: [CodableNew]
        let timestamp: Date

        var localNews: [LocalLiveHackrNew] {
            news.map(\.local)
        }
    }

    private struct CodableNew: Codable {
        private let id: Int

        init(_ localLiveHackrNew: LocalLiveHackrNew) {
            id = localLiveHackrNew.id
        }

        var local: LocalLiveHackrNew {
            LocalLiveHackrNew(id: id)
        }
    }

    private let storeUrl: URL

    init(storeURL: URL) {
        storeUrl = storeURL
    }

    func retrieve(completion: @escaping LiveHackrNewsStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let decoded = try! decoder.decode(Cache.self, from: data)
        completion(.found(news: decoded.localNews, timestamp: decoded.timestamp))
    }

    func insertCacheNews(_ news: [LocalLiveHackrNew], with timestamp: Date, completion: @escaping LiveHackrNewsStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(news: news.map(CodableNew.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeUrl)
        completion(nil)
    }
}

final class CodableHackrNewsStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        try? FileManager.default.removeItem(at: storeURL())
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: storeURL())
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
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
        let sut = makeSUT()
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
        let sut = makeSUT()
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

    // MARK: Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableHackrNewsStore {
        let sut = CodableHackrNewsStore(storeURL: storeURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func storeURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("news.store")
    }
}
