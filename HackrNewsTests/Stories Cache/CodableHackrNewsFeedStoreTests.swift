//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class CodableHackrNewsFeedStore {
    private struct Cache: Codable {
        let news: [CodableHackrNew]
        let timestamp: Date

        var localFeed: [LocalHackrNew] {
            news.map(\.local)
        }
    }

    private struct CodableHackrNew: Codable {
        private let id: Int

        init(_ localHackrNew: LocalHackrNew) {
            id = localHackrNew.id
        }

        var local: LocalHackrNew {
            LocalHackrNew(id: id)
        }
    }

    private let storeUrl: URL

    init(storeURL: URL) {
        storeUrl = storeURL
    }

    func retrieve(completion: @escaping HackrNewsFeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let decoded = try! decoder.decode(Cache.self, from: data)
        completion(.found(news: decoded.localFeed, timestamp: decoded.timestamp))
    }

    func insertCacheNews(_ news: [LocalHackrNew], with timestamp: Date, completion: @escaping HackrNewsFeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(news: news.map(CodableHackrNew.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeUrl)
        completion(nil)
    }
}

final class CodableHackrNewsFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
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
        let news = [LocalHackrNew(id: 1), LocalHackrNew(id: 2), LocalHackrNew(id: 3)]
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

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableHackrNewsFeedStore {
        let sut = CodableHackrNewsFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func deleteStoreArtifacts() -> Void? {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
}
