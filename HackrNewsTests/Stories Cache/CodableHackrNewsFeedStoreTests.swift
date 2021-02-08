//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class CodableHackrNewsFeedStore: HackrNewsFeedStore {
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

    func retrieve(completion: @escaping RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Cache.self, from: data)
            completion(.found(news: decoded.localFeed, timestamp: decoded.timestamp))
        } catch {
            completion(.failure(error))
        }
    }

    func insertCacheNews(_ news: [LocalHackrNew], with timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let cache = Cache(news: news.map(CodableHackrNew.init), timestamp: timestamp)
            let encoded = try encoder.encode(cache)
            try encoded.write(to: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func deleteCachedNews(completion: @escaping DeletionCompletion) {
        do {
            guard FileManager.default.fileExists(atPath: storeUrl.path) else {
                return completion(.none)
            }
            try FileManager.default.removeItem(at: storeUrl)
            completion(.none)
        } catch {
            completion(error)
        }
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

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
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

    func test_retrieve_deliversErrorOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, retrieves: .failure(anyNSError()))
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        expect(sut, retrievesTwice: .failure(anyNSError()))
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let uniqueFeed = [LocalHackrNew(id: 1), LocalHackrNew(id: 2), LocalHackrNew(id: 3)]

        let firstInsertionError = insert(cache: (feed: uniqueFeed, timestamp: Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")

        let latestFeed = [LocalHackrNew(id: 4), LocalHackrNew(id: 5), LocalHackrNew(id: 6)]
        let latestTimestamp = Date()
        let latestInsertionError = insert(cache: (latestFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected to override cache successfully")

        expect(sut, retrieves: .found(news: latestFeed, timestamp: latestTimestamp))
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreUrl = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreUrl)
        let feed = [LocalHackrNew(id: 1), LocalHackrNew(id: 2), LocalHackrNew(id: 3)]
        let timestamp = Date()

        let insertionError = insert(cache: (feed: feed, timestamp: timestamp), to: sut)

        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func test_delete_emptiesPreviousInsertedCache() {
        let sut = makeSUT()
        let feed = [LocalHackrNew(id: 1), LocalHackrNew(id: 2), LocalHackrNew(id: 3)]
        let timestamp = Date()

        insert(cache: (feed: feed, timestamp: timestamp), to: sut)
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func test_delete_deliversErrorOnDeletionError() {
        let sut = makeSUT(storeURL: noDeletePermissionURL())

        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
    }

    // MARK: Helpers

    private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> HackrNewsFeedStore {
        let sut = CodableHackrNewsFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func noDeletePermissionURL() -> URL {
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .systemDomainMask
        ).first!
    }

    @discardableResult
    private func insert(
        cache: (feed: [LocalHackrNew], timestamp: Date),
        to sut: HackrNewsFeedStore,
        file _: StaticString = #filePath,
        line _: UInt = #line
    ) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var error: Error?

        sut.insertCacheNews(cache.feed, with: cache.timestamp) { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        return error
    }

    private func deleteCache(from sut: HackrNewsFeedStore) -> Error? {
        var deletionError: Error?
        let exp = expectation(description: "Wait for deletion completion")

        sut.deleteCachedNews { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    private func expect(
        _ sut: HackrNewsFeedStore,
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
            case (.failure, .failure):
                break
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
        _ sut: HackrNewsFeedStore,
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
