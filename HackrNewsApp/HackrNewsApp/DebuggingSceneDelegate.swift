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
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
        return super.makeRemoteClient()
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

#endif
