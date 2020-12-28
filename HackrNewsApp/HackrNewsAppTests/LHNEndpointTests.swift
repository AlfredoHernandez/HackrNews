//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import HackrNewsApp
import XCTest

class LHNEndpointTests: XCTestCase {
    func test_newStoriesUrl_isCorrectURL() {
        let endpoint = LHNEndpoint.newStories.url()

        XCTAssertEqual(endpoint.absoluteString, "https://hacker-news.firebaseio.com/v0/newstories.json")
    }
}
