//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let httpClient = makeRemoteClient()
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: url, client: httpClient)
        let hackrStoryLoader = RemoteHackrStoryLoader(client: httpClient)
        let controller = LiveHackrNewsUIComposer.composeWith(liveHackrNewsloader: liveHackrNewsloader, hackrStoryLoader: hackrStoryLoader)
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
    }

    private func makeRemoteClient() -> HTTPClient {
        switch UserDefaults.standard.string(forKey: "connectivity") {
        case "offline":
            return AlwaysFailingHTTPClient()
        default:
            return URLSessionHTTPClient(session: URLSession(configuration: .default))
        }
    }
}

final class AlwaysFailingHTTPClient: HTTPClient {
    struct Task: HTTPClientTask {
        func cancel() {}
    }

    func get(from _: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) -> HTTPClientTask {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
            completion(.failure(NSError(domain: "com.alfredohdz.hackr-news-app.acceptance-tests", code: 0, userInfo: nil)))
        }
        return Task()
    }
}
