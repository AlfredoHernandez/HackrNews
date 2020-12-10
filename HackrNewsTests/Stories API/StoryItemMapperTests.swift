//
//  StoryItemMapper.swift
//  HackrNews
//
//  Created by Jesús Alfredo Hernández Alarcón on 10/12/20.
//  
//

import XCTest
import Foundation
import HackrNews

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
}
