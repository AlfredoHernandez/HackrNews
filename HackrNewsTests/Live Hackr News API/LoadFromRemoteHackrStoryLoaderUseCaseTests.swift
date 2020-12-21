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

    func test_loadDataFromURL_requestDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()

        sut.load(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadDataFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()

        sut.load(from: url) { _ in }
        sut.load(from: url) { _ in }

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

    // MARK: Tests helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteHackrStoryLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteHackrStoryLoader(client: client)
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
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")

        sut.load(from: url) { receivedResult in
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
