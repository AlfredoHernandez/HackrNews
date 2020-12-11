//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews
import XCTest

final class StoryItemMapperTests: XCTestCase {
    func test_map_throwsInvalidDataErrorOnNon200HTTPResponses() throws {
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(try StoryItemMapper.map(data: anyData(), response: HTTPURLResponse(statusCode: code)))
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSONData() {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(try StoryItemMapper.map(data: invalidJSON, response: HTTPURLResponse(statusCode: 200)))
    }

    func test_map_deliversAStoryOn200HTTPResponseWithValidJSONData() throws {
        let (data, model) = makeItem(
            id: 1,
            title: "a title",
            author: "a username",
            score: 100,
            createdAt: (Date(timeIntervalSince1970: 1607645758000), 1607645758000),
            totalComments: 0,
            comments: [123, 456],
            type: "a type",
            url: anyURL()
        )

        let story = try StoryItemMapper.map(data: data, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(story.id, model.id)
        XCTAssertEqual(story.title, model.title)
        XCTAssertEqual(story.author, model.author)
        XCTAssertEqual(story.comments, model.comments)
        XCTAssertEqual(story.totalComments, model.totalComments)
        XCTAssertEqual(story.createdAt, model.createdAt)
        XCTAssertEqual(story.type, model.type)
        XCTAssertEqual(story.url, model.url)
    }

    // MARK: - Helpers

    private func makeItem(
        id: Int,
        title: String,
        author: String,
        score: Int,
        createdAt: (date: Date, unixTime: Double),
        totalComments: Int,
        comments: [Int],
        type: String,
        url: URL
    ) -> (data: Data, model: Story) {
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
            "id": id,
            "title": title,
            "by": author,
            "descendants": totalComments,
            "kids": comments,
            "score": score,
            "time": createdAt.unixTime,
            "type": type,
            "url": url.absoluteString,
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        return (data, model)
    }
}
