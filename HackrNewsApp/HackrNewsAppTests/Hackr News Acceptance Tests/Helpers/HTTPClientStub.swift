//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

final class HTTPClientStub: HTTPClient {
    private let stub: (URL) -> HTTPClient.Result

    struct Task: HTTPClientTask {
        func cancel() {}
    }

    init(stub: @escaping (URL) -> HTTPClient.Result) {
        self.stub = stub
    }

    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        completion(stub(url))
        return Task()
    }

    static var offline: HTTPClientStub {
        HTTPClientStub { _ in .failure(NSError(domain: "offline", code: 0, userInfo: nil)) }
    }

    static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
        HTTPClientStub { url in .success(stub(url)) }
    }
}

func response(for url: URL) -> (Data, HTTPURLResponse) {
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return (makeData(for: url), response)
}

func cachedStoriesResponse(for url: URL) -> (Data, HTTPURLResponse) {
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return (makePartialData(for: url), response)
}

private func makePartialData(for url: URL) -> Data {
    if url.absoluteString.contains("https://hacker-news.firebaseio.com/v0/item/") {
        return Data("invalid-data".utf8)
    } else {
        return makeData(for: url)
    }
}

private func makeData(for url: URL) -> Data {
    if url.absoluteString.contains("https://hacker-news.firebaseio.com/v0/item/") {
        return makeStoryData()
    } else {
        return makeHackrNewsFeedData()
    }
}

private func makeStoryData() -> Data {
    try! JSONSerialization.data(withJSONObject: [
        "by": "AlfredoHernandez",
        "descendants": 1,
        "id": 1,
        "kids": makeComments(),
        "score": 100,
        "time": 1175714200,
        "title": "Welcome to HackrNewsApp",
        "text": "Hello, World!",
        "type": "story",
        "url": "http://alfredohdz.com/HackrNews",
    ])
}

private func makeHackrNewsFeedData() -> Data {
    try! JSONSerialization.data(withJSONObject: [1, 2, 3, 4, 5])
}

private func makeComments() -> [Int] {
    [1, 2, 3, 4, 5]
}
