//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LoadFromRemoteHackrStoryLoaderUseCaseTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    // MARK: Tests helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteHackrStoryLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteHackrStoryLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
}
