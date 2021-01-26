//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class StoryItemMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResonse() throws {
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(try StoryItemMapper.map(data: makeItemJSON([:]), response: HTTPURLResponse(statusCode: code))) { error in
                XCTAssertEqual(error as? StoryItemMapper.Error, .invalidData)
            }
        }
    }

    func test_map_throwsInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data()

        XCTAssertThrowsError(try StoryItemMapper.map(data: emptyData, response: HTTPURLResponse(statusCode: 200))) { error in
            XCTAssertEqual(error as? StoryItemMapper.Error, .invalidData)
        }
    }

    func test_map_deliversItemOn200HTTPResponse() throws {
        let item = makeItem(createdAt: (Date(timeIntervalSince1970: 1175714200), 1175714200))

        let result = try StoryItemMapper.map(data: item.data, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, item.model)
    }

    // MARK: Tests helpers

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
