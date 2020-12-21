//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

class RemoteLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliverConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: .failure(anyNSError()))
        })
    }

    func test_deliversErrorOnMapperError() {
        let (sut, client) = makeSUT(mapper: { _, _ in
            throw anyNSError()
        })

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversMappedResource() {
        let resource = "a resource"
        let (sut, client) = makeSUT(mapper: { data, _ in
            String(data: data, encoding: .utf8)!
        })

        expect(sut, toCompleteWith: .success(resource), when: {
            let data = Data(resource.utf8)
            client.complete(withStatusCode: 200, data: data)
        })
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteLoader? = RemoteLoader<String>(client: client, url: anyURL(), mapper: { _, _ in "any" })

        var receivedResults = [RemoteLoader<String>.Result]()
        sut?.load { receivedResults.append($0) }

        sut = nil
        client.complete(with: .failure(anyNSError()))

        XCTAssertTrue(receivedResults.isEmpty, "Should not deliver results after instance has been deallocated")
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteLoader<String>(client: client, url: url, mapper: mapper)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        .failure(error)
    }

    private func expect(
        _ sut: RemoteLoader<String>,
        toCompleteWith expectedResult: RemoteLoader<String>.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), but got \(receivedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
}
