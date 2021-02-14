//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class HackrNewsFeedLoaderWithFallbackComposite: HackrNewsFeedLoader {
    private let primary: HackrNewsFeedLoader

    init(primary: HackrNewsFeedLoader, fallback _: HackrNewsFeedLoader) {
        self.primary = primary
    }

    func load(completion: @escaping (HackrNewsFeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

final class HackrNewsFeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryResult = uniqueFeed()
        let fallbackResult = uniqueFeed()
        let primary = LoaderStub(.success(primaryResult))
        let fallback = LoaderStub(.success(fallbackResult))
        let sut = HackrNewsFeedLoaderWithFallbackComposite(primary: primary, fallback: fallback)
        let exp = expectation(description: "Wait loader for completion")

        sut.load { receivedResult in
            switch receivedResult {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryResult)
            default:
                break
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
    }

    // MARK: - Helpers

    private func uniqueFeed() -> [HackrNew] {
        [HackrNew(id: Int.random(in: 0 ... 100)), HackrNew(id: Int.random(in: 0 ... 100)), HackrNew(id: Int.random(in: 0 ... 100))]
    }

    private class LoaderStub: HackrNewsFeedLoader {
        private let result: HackrNewsFeedLoader.Result

        init(_ result: HackrNewsFeedLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (HackrNewsFeedLoader.Result) -> Void) {
            completion(result)
        }
    }
}
