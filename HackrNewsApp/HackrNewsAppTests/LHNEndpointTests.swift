//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import HackrNewsApp
import XCTest

class LHNEndpointTests: XCTestCase {
    func test_baseUrl_isCorrect() {
        XCTAssertEqual(Endpoint.baseUrl.absoluteString, "https://hacker-news.firebaseio.com")
    }

    func test_newStoriesUrl_isCorrectURL() {
        let baseUrl = URL(string: "http://any-url.com")!
        let endpoint = Endpoint.newStories.url(baseUrl)

        XCTAssertEqual(endpoint.absoluteString, "http://any-url.com/v0/newstories.json")
    }

    func test_topStoriesUrl_isCorrectURL() {
        let baseUrl = URL(string: "http://any-url.com")!
        let endpoint = Endpoint.topStories.url(baseUrl)

        XCTAssertEqual(endpoint.absoluteString, "http://any-url.com/v0/topstories.json")
    }

    func test_bestStoriesURL() {
        let baseUrl = URL(string: "http://any-url.com")!
        let endpoint = Endpoint.bestStories.url(baseUrl)

        XCTAssertEqual(endpoint.absoluteString, "http://any-url.com/v0/beststories.json")
    }

    func test_itemUrl() {
        let baseUrl = URL(string: "http://any-url.com")!
        let id = 1993
        let endpoint = Endpoint.item(id).url(baseUrl)

        XCTAssertEqual(endpoint.absoluteString, "http://any-url.com/v0/item/1993.json")
    }
}
