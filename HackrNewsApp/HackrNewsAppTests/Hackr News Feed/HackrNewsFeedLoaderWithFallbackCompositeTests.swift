//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import XCTest

final class HackrNewsFeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryResult = uniqueFeed()
        let fallbackResult = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryResult), fallbackResult: .success(fallbackResult))

        expect(sut, toCompleteWith: .success(primaryResult))
    }

    func test_load_deliversFallbackFeedOnPrimaryLoaderFailure() {
        let fallbackResult = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackResult))

        expect(sut, toCompleteWith: .success(fallbackResult))
    }

    func test_load_deliversErrorOnFallbackLoaderFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))

        expect(sut, toCompleteWith: .failure(anyNSError()))
    }

    // MARK: - Helpers

    private func makeSUT(
        primaryResult: HackrNewsFeedLoader.Result,
        fallbackResult: HackrNewsFeedLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HackrNewsFeedLoaderWithFallbackComposite {
        let primaryLoader = FeedLoaderStub(primaryResult)
        let fallbackLoader = FeedLoaderStub(fallbackResult)
        let sut = HackrNewsFeedLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        return sut
    }

    private func expect(
        _ sut: HackrNewsFeedLoaderWithFallbackComposite,
        toCompleteWith expectedResult: HackrNewsFeedLoader.Result,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait loader for completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(
                    receivedFeed,
                    expectedFeed,
                    "Expected to complete with \(expectedFeed), but got \(receivedFeed) instead",
                    file: file,
                    line: line
                )
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }
}
