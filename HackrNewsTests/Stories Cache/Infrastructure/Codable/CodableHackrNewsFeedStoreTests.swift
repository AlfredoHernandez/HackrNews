//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

typealias FailableHackrNewsFeedStore = HackrNewsFeedStoreSpecs & FailableRetrieveHackrNewsFeedStoreSpecs &
    FailableInsertHackrNewsFeedStoreSpecs & FailableDeleteHackrNewsFeedStoreSpecs

final class CodableHackrNewsFeedStoreTests: XCTestCase, FailableHackrNewsFeedStore {
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

        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffects() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffects(on: sut)
    }

    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()

        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }

    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }

    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)

        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)

        assertThatRetrievehasNoSideEffectsOnFailure(on: sut)
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }

    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreUrl = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreUrl)

        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }

    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreUrl = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreUrl)

        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }

    func test_delete_emptiesPreviousInsertedCache() {
        let sut = makeSUT()
        assertThatDeleteEmptiesPreviousInsertedCache(on: sut)
    }

    func test_delete_deliversErrorOnDeletionError() {
        let sut = makeSUT(storeURL: noDeletePermissionURL())

        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }

    func test_delete_hasNoSideEffectsOnDeletionError() {
        let sut = makeSUT(storeURL: noDeletePermissionURL())

        assertThatDeletehasNoSideEffectsOnDeletionError(on: sut)
    }

    func test_storeSideEffects_runsSerially() {
        let sut = makeSUT()

        assertThatStoreSideEffectsRunsSerially(on: sut)
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
