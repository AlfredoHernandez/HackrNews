//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import HackrNewsiOS
import XCTest

final class HackrNewsAppAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteStoriesWhenCustomerHasConnectivity() {
        let storiesViewController = launch(httpClient: .online(response))

        XCTAssertEqual(storiesViewController.numberOfRenderedLiveHackrNewsViews(), 5)
        XCTAssertNotNil(storiesViewController.simulateStoryViewVisible(at: 0))
        XCTAssertNotNil(storiesViewController.simulateStoryViewVisible(at: 1))
    }

    func test_onLaunch_doesNotDisplayRemoteStoriesWhenCustomerHasNotConnectivity() {
        let storiesViewController = launch(httpClient: .offline)

        XCTAssertEqual(storiesViewController.numberOfRenderedLiveHackrNewsViews(), 0)
    }

    func test_onSelectStory_displaysStoryUrlInSafari() {}

    // MARK: - Helpers

    private func launch(httpClient: HTTPClientStub = .offline) -> LiveHackrNewsViewController {
        let sut = SceneDelegate(httpClient: httpClient)
        sut.window = UIWindow()

        sut.configureWindow()

        let tabBarController = sut.window?.rootViewController as! UITabBarController
        let navigationController = tabBarController.viewControllers?.first as! UINavigationController
        let storiesViewController = navigationController.topViewController as! LiveHackrNewsViewController
        return storiesViewController
    }

    private final class HTTPClientStub: HTTPClient {
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

    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        if url.absoluteString.contains("https://hacker-news.firebaseio.com/v0/item/") {
            return makeStoryData()
        } else {
            return makeLiveHackrNewsData()
        }
    }

    private func makeStoryData() -> Data {
        try! JSONSerialization.data(withJSONObject: [
            "by": "AlfredoHernandez",
            "descendants": 1,
            "id": 1,
            "kids": [2],
            "score": 100,
            "time": 1175714200,
            "title": "Welcome to HackrNewsApp",
            "type": "story",
            "url": "http://alfredohdz.com/HackrNews",
        ])
    }

    private func makeLiveHackrNewsData() -> Data {
        try! JSONSerialization.data(withJSONObject: [1, 2, 3, 4, 5])
    }
}
