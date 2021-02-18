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
        let item = makeItem(
            id: 1,
            title: "a title",
            text: "a text",
            author: "any author",
            score: 10,
            createdAt: (Date(timeIntervalSince1970: 1175714200), 1175714200),
            totalComments: 3,
            comments: [1, 2, 3],
            type: "story",
            url: anyURL()
        )

        let result = try StoryItemMapper.map(data: item.data, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, item.model)
    }

    func test_map_deliversItemWithoutAllPropertiesOn200HTTPResponse() throws {
        let item = makeItem(
            id: 1,
            title: nil,
            text: nil,
            author: "any author",
            score: nil,
            createdAt: (Date(timeIntervalSince1970: 1175714200), 1175714200),
            totalComments: nil,
            comments: nil,
            type: "story",
            url: nil
        )

        let result = try StoryItemMapper.map(data: item.data, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, item.model)
    }

    // MARK: Tests helpers

    private func makeItem(
        id: Int = 1,
        title: String? = nil,
        text: String? = nil,
        author: String = "an author",
        score: Int? = nil,
        createdAt: (date: Date, value: Double) = (Date(timeIntervalSince1970: 1175714200), 1175714200),
        totalComments: Int? = nil,
        comments: [Int]? = nil,
        type: String = "story",
        url: URL? = nil
    ) -> (model: Story, data: Data) {
        let model = Story(
            id: id,
            title: title,
            text: text,
            author: author,
            score: score,
            createdAt: createdAt.date,
            totalComments: totalComments,
            comments: comments,
            type: type,
            url: url
        )
        let tempJson: [String: Any?] = [
            "by": author,
            "descendants": totalComments,
            "id": id,
            "kids": comments,
            "score": score,
            "time": createdAt.value,
            "title": title,
            "text": text,
            "type": type,
            "url": url?.absoluteString,
        ]
        let json = tempJson.compactMapValues { $0 }
        let data = makeItemJSON(json)
        return (model, data)
    }

    private func makeItemJSON(_ item: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: item)
    }
}
