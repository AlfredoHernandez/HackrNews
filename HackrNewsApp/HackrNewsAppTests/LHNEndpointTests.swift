//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import HackrNewsApp
import XCTest

class LHNEndpointTests: XCTestCase {
    func test_baseUrl_isCorrect() {
        XCTAssertEqual(LHNEndpoint.baseUrl.absoluteString, "https://hacker-news.firebaseio.com")
    }

    func test_newStoriesUrl_isCorrectURL() {
        let baseUrl = URL(string: "http://any-url.com")!
        let endpoint = LHNEndpoint.newStories.url(baseUrl)

        XCTAssertEqual(endpoint.absoluteString, "http://any-url.com/v0/newstories.json")
    }

    func test_topStoriesUrl_isCorrectURL() {
        let baseUrl = URL(string: "http://any-url.com")!
        let endpoint = LHNEndpoint.topStories.url(baseUrl)

        XCTAssertEqual(endpoint.absoluteString, "http://any-url.com/v0/topstories.json")
    }
    
    func test_itemUrl() {
        let baseUrl = URL(string: "http://any-url.com")!
        let id = 1993
        let endpoint = LHNEndpoint.item(id).url(baseUrl)
        
        XCTAssertEqual(endpoint.absoluteString, "http://any-url.com/v0/item/1993.json")
        
    }
}
