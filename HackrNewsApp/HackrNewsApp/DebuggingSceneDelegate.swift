//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

#if DEBUG
import HackrNews
import UIKit

class DebuggingSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }

    override func makeRemoteClient() -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity") {
            return DebuggingHTTPClient(connectivity: connectivity)
        }
        return super.makeRemoteClient()
    }
}

final class DebuggingHTTPClient: HTTPClient {
    let connectivity: String

    init(connectivity: String) {
        self.connectivity = connectivity
    }

    struct Task: HTTPClientTask {
        func cancel() {}
    }

    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        switch connectivity {
        case "online":
            completion(.success(makeSuccessfulResponse(for: url)))
        default:
            completion(.failure(NSError(domain: "com.alfredohdz.hackr-news-app.acceptance-tests.offline", code: 0, userInfo: nil)))
        }
        return Task()
    }

    private func makeSuccessfulResponse(for url: URL) -> (Data, HTTPURLResponse) {
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

#endif
