//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import XCTest

final class HackrStoryLoaderWithFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadStoryData() {
        let (_, primary, fallback) = makeSUT()

        XCTAssertTrue(primary.loadedStories.isEmpty, "Expected to no request story data")
        XCTAssertTrue(fallback.loadedStories.isEmpty, "Expected to no request story data")
    }

    func test_load_startsLoadingFromPrimaryLoaderFirst() {
        let (sut, primary, fallback) = makeSUT()
        let id = anyID()

        sut.load(id: id) { _ in }

        XCTAssertEqual(primary.loadedStories, [id], "Expected to request story data")
        XCTAssertTrue(fallback.loadedStories.isEmpty, "Expected to no request story data")
    }

    func test_load_startsLoadingFromFallbackOnPrimaryLoaderFailure() {
        let (sut, primary, fallback) = makeSUT()
        let id = anyID()

        sut.load(id: id) { _ in }
        primary.completes(with: anyNSError())

        XCTAssertEqual(primary.loadedStories, [id], "Expected to request story data")
        XCTAssertEqual(fallback.loadedStories, [id], "Expected to request story data")
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (HackrStoryLoaderWithFallbackComposite, HackrStoryLoaderSpy, HackrStoryLoaderSpy) {
        let primary = HackrStoryLoaderSpy()
        let fallback = HackrStoryLoaderSpy()
        let sut = HackrStoryLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primary, file: file, line: line)
        trackForMemoryLeaks(fallback, file: file, line: line)
        return (sut, primary, fallback)
    }

    private class HackrStoryLoaderSpy: HackrStoryLoader {
        var completions = [(id: Int, completion: (HackrStoryLoader.Result) -> Void)]()

        var loadedStories: [Int] { completions.map(\.id) }

        class Task: HackrStoryLoaderTask {
            func cancel() {}
        }

        func load(id: Int, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
            completions.append((id, completion))
            return Task()
        }

        func completes(with error: Error, at index: Int = 0) {
            completions[index].completion(.failure(error))
        }
    }

    private func anyID() -> Int { Int.random(in: 0 ... 100) }
}
