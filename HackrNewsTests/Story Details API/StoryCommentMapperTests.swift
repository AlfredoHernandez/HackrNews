//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class StoryCommentMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResonse() throws {
        let json = makeItemJSON(makeItem().json)
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(try StoryCommentMapper.map(data: json, response: HTTPURLResponse(statusCode: code))) { error in
                XCTAssertEqual(error as? StoryCommentMapper.Error, .invalidData)
            }
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(try StoryCommentMapper.map(data: invalidJSON, response: HTTPURLResponse(statusCode: 200))) { error in
            XCTAssertEqual(error as? StoryCommentMapper.Error, .invalidData)
        }
    }

    func tests_map_deliversStoryCommentOn200HTTPResponseWithJSONItems() throws {
        // Sunday, 24 January 2021 00:00:00 GMT-06:00
        let fixedDate = (
            date: Date(timeIntervalSince1970: 1611468000000),
            posix: Double(1611468000000)
        )
        let item = makeItem(id: 1, author: "an author", comments: [2], parent: 0, text: "a text", createdAt: fixedDate, type: "comment")
        let json = makeItemJSON(item.json)

        let result = try StoryCommentMapper.map(data: json, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, item.model)
    }

    func tests_map_deliversStoryCommentWithoutChildCommentsOn200HTTPResponseWithJSONItems() throws {
        // Sunday, 24 January 2021 00:00:00 GMT-06:00
        let fixedDate = (
            date: Date(timeIntervalSince1970: 1611468000000),
            posix: Double(1611468000000)
        )
        let item = makeItem(id: 1, author: "an author", comments: nil, parent: 0, text: "a text", createdAt: fixedDate, type: "comment")
        let json = makeItemJSON(item.json)

        let result = try StoryCommentMapper.map(data: json, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, item.model)
    }

    // MARK: Tests helpers

    private func makeItem(
        id: Int = 1,
        author: String = "author",
        comments: [Int]? = nil,
        parent: Int = 0,
        text: String = "text",
        createdAt: (date: Date, posix: Double) = (date: Date(timeIntervalSince1970: 1611468000000), posix: Double(1611468000000)),
        type: String = "comment"
    ) -> (model: StoryComment, json: [String: Any]) {
        // Used fixed date: Sunday, 24 January 2021 00:00:00 GMT-06:00
        let item = StoryComment(
            id: id,
            author: author,
            comments: comments ?? [],
            parent: parent,
            text: text,
            createdAt: createdAt.date,
            type: type
        )
        let json = [
            "id": id,
            "by": author,
            "kids": comments as Any,
            "parent": parent,
            "text": text,
            "time": createdAt.posix,
            "type": type,
        ].compactMapValues { $0 }
        return (item, json)
    }

    private func makeItemJSON(_ json: [String: Any]) -> Data {
        try! JSONSerialization.data(withJSONObject: json)
    }
}
