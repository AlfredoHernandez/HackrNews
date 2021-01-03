//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LoadFromRemoteHackrStoryLoaderUseCaseTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadDataFromURL_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        _ = sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadDataFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        _ = sut.load { _ in }
        _ = sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_loadDataFromURL_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: clientError)
        })
    }

    func test_loadDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(with: code, data: anyData(), at: index)
            })
        }
    }

    func test_loadDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(with: 200, data: emptyData)
        })
    }

    func test_loadDataFromURL_deliversItemOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let item = makeItem(createdAt: (Date(timeIntervalSince1970: 1175714200), 1175714200))

        expect(sut, toCompleteWith: .success(item.model), when: {
            client.complete(with: 200, data: item.data)
        })
    }

    func test_cancelLoadDataTask_cancelsClientURLRequest() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        let task = sut.load { _ in }

        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }

    func test_loadDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let url = URL(string: "https://a-given-url.com")!
        let nonEmptyData = Data("non-empty data".utf8)
        let (sut, client) = makeSUT(url: url)

        var received = [RemoteHackrStoryLoader.Result]()
        let task = sut.load { result in
            received.append(result)
        }
        task.cancel()

        client.complete(with: 404, data: anyData())
        client.complete(with: 200, data: nonEmptyData)
        client.complete(with: anyNSError())

        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }

    func test_loadDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteHackrStoryLoader? = RemoteHackrStoryLoader(url: anyURL(), client: client)

        var capturedResults = [RemoteHackrStoryLoader.Result]()
        _ = sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(with: 200, data: anyData())

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: Tests helpers

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteHackrStoryLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteHackrStoryLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func expect(
        _ sut: RemoteHackrStoryLoader,
        toCompleteWith expectedResult: RemoteHackrStoryLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        _ = sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteHackrStoryLoader.Error) -> RemoteHackrStoryLoader.Result {
        .failure(error)
    }

    private func makeItem(
        id: Int = 1,
        title: String = "a title",
        author: String = "an author",
        score: Int = 0,
        createdAt: (date: Date, value: Double) = (Date(timeIntervalSince1970: 1175714200), 1175714200),
        totalComments: Int = 0,
        comments: [Int] = [],
        type: String = "story",
        url: URL = anyURL()
    ) -> (model: Story, data: Data) {
        let model = Story(
            id: id,
            title: title,
            author: author,
            score: score,
            createdAt: createdAt.date,
            totalComments: totalComments,
            comments: comments,
            type: type,
            url: url
        )
        let json: [String: Any] = [
            "by": author,
            "descendants": totalComments,
            "id": id,
            "kids": comments,
            "score": score,
            "time": createdAt.value,
            "title": title,
            "type": type,
            "url": url.absoluteString,
        ]
        let data = makeItemJSON(json)
        return (model, data)
    }

    private func makeItemJSON(_ item: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: item)
    }
}
