//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LiveDataMapperTests: XCTestCase {
    func test_map_throwsErrorOnNon200HTTPResonse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(try LiveDataMapper.map(data: json, response: HTTPURLResponse(statusCode: code))) { error in
                XCTAssertEqual(error as? RemoteLiveHackrNewsLoader.Error, .invalidData)
            }
        }
    }

    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)
        XCTAssertThrowsError(try LiveDataMapper.map(data: invalidJSON, response: HTTPURLResponse(statusCode: 200))) { error in
            XCTAssertEqual(error as? RemoteLiveHackrNewsLoader.Error, .invalidData)
        }
    }

    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyListJSON = makeItemsJSON([])

        let result = try LiveDataMapper.map(data: emptyListJSON, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [], "Expected no items, but got \(result)")
    }

    func tests_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        let item1 = makeItem(id: 1)
        let item2 = makeItem(id: 2)
        let itemsJSON = makeItemsJSON([item1.json, item2.json])

        let result = try LiveDataMapper.map(data: itemsJSON, response: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [item1.model, item2.model], "Expected no items, but got \(result)")
    }

    // MARK: Tests helpers

    private func makeItem(id: Int) -> (model: LiveHackrNew, json: Int) {
        let item = LiveHackrNew(id: id)
        return (item, item.id)
    }

    private func makeItemsJSON(_ items: [Int]) -> Data {
        try! JSONSerialization.data(withJSONObject: items)
    }
}
