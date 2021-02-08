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

        expect(sut, retrieves: .empty)
    }

    func test_retrieve_hasNoSideEffects() {
        let sut = makeSUT()

        expect(sut, retrievesTwice: .empty)
    }

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let news = [LocalHackrNew(id: 1), LocalHackrNew(id: 2), LocalHackrNew(id: 3)]
        let timestamp = Date()

        insert(cache: (news, timestamp), to: sut)

        expect(sut, retrieves: .found(news: news, timestamp: timestamp))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let news = [LocalHackrNew(id: 1), LocalHackrNew(id: 2), LocalHackrNew(id: 3)]
        let timestamp = Date()

        insert(cache: (news, timestamp), to: sut)

        expect(sut, retrievesTwice: .found(news: news, timestamp: timestamp))
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

    private func insert(
        cache: (feed: [LocalHackrNew], timestamp: Date),
        to sut: CodableHackrNewsFeedStore,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache insertion")

        sut.insertCacheNews(cache.feed, with: cache.timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected news to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func expect(
        _ sut: CodableHackrNewsFeedStore,
        retrieves expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
                break
            case let (.found(news: retrievedNews, timestamp: retrievedTimestamp), .found(news: expectedNews, timestamp: expectedTimestamp)):
                XCTAssertEqual(retrievedNews, expectedNews, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
            default:
                XCTFail(
                    "Expected \(expectedResult), got \(retrievedResult) instead.",
                    file: file,
                    line: line
                )
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func expect(
        _ sut: CodableHackrNewsFeedStore,
        retrievesTwice expectedResult: RetrieveCachedFeedResult,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) {
        expect(sut, retrieves: expectedResult)
        expect(sut, retrieves: expectedResult)
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
