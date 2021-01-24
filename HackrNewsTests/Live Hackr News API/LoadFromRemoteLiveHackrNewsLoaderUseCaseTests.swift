//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LoadFromRemoteLiveHackrNewsLoaderUseCaseTests: XCTestCase {
    func test_load_deliversErrorOnNon200HTTPResonse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJSON([])
                client.complete(with: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(with: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemsJSON([])
            client.complete(with: 200, data: emptyListJSON)
        })
    }

    func tests_load_deliversItemsOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(id: 1)
        let item2 = makeItem(id: 2)

        let items = [item1.model, item2.model]

        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(with: 200, data: json)
        })
    }

    // MARK: Tests helpers

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteLiveHackrNewsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLiveHackrNewsLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteLiveHackrNewsLoader.Error) -> RemoteLiveHackrNewsLoader.Result {
        .failure(error)
    }

    private func makeItem(id: Int) -> (model: LiveHackrNew, json: Int) {
        let item = LiveHackrNew(id: id)
        return (item, item.id)
    }

    private func makeItemsJSON(_ items: [Int]) -> Data {
        try! JSONSerialization.data(withJSONObject: items)
    }

    private func expect(
        _ sut: RemoteLiveHackrNewsLoader,
        toCompleteWith expectedResult: RemoteLiveHackrNewsLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (
                .failure(receivedError as RemoteLiveHackrNewsLoader.Error),
                .failure(expectedError as RemoteLiveHackrNewsLoader.Error)
            ):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail(
                    "Expected result \(expectedResult) but got \(receivedResult) instead.",
                    file: file,
                    line: line
                )
            }
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
