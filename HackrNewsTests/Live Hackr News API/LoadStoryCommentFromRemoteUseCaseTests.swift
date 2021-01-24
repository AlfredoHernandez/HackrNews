//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LoadStoryCommentFromRemoteUseCaseTests: XCTestCase {
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

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResonse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemJSON(makeItem().json)
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

    func tests_load_deliversStoryCommentOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        let fixedDate = (
            date: Date(timeIntervalSince1970: 1611468000000),
            posix: Double(1611468000000)
        ) // Sunday, 24 January 2021 00:00:00 GMT-06:00

        let item = makeItem(id: 1, author: "an author", comments: [2], parent: 0, text: "a text", createdAt: fixedDate, type: "comment")

        expect(sut, toCompleteWith: .success(item.model), when: {
            let json = makeItemJSON(item.json)
            client.complete(with: 200, data: json)
        })
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteStoryCommentLoader? = RemoteStoryCommentLoader(url: url, client: client)

        var capturedResults = [RemoteStoryCommentLoader.Result]()
        sut?.load { capturedResults.append($0) }
        sut = nil
        client.complete(with: 200, data: makeItemJSON(makeItem().json))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: Tests helpers

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteStoryCommentLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteStoryCommentLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteStoryCommentLoader.Error) -> RemoteStoryCommentLoader.Result {
        .failure(error)
    }

    // Used fixed date: Sunday, 24 January 2021 00:00:00 GMT-06:00,
    private func makeItem(
        id: Int = 1,
        author: String = "author",
        comments: [Int] = [],
        parent: Int = 0,
        text: String = "text",
        createdAt: (date: Date, posix: Double) = (date: Date(timeIntervalSince1970: 1611468000000), posix: Double(1611468000000)),
        type: String = "comment"
    ) -> (model: StoryComment, json: [String: Any]) {
        let item = StoryComment(
            id: id,
            author: author,
            comments: comments,
            parent: parent,
            text: text,
            createdAt: createdAt.date,
            type: type
        )
        let json: [String: Any] = [
            "id": id,
            "by": author,
            "kids": comments,
            "parent": parent,
            "text": text,
            "time": createdAt.posix,
            "type": type,
        ]
        return (item, json)
    }

    private func makeItemJSON(_ json: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(
        _ sut: RemoteStoryCommentLoader,
        toCompleteWith expectedResult: RemoteStoryCommentLoader.Result,
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
                .failure(receivedError as RemoteStoryCommentLoader.Error),
                .failure(expectedError as RemoteStoryCommentLoader.Error)
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
