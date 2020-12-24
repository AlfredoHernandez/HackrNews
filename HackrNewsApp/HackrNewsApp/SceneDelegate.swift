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
        configureWindow()
    }

    func configureWindow() {
        makeTabBarViewController(with: [makeLiveHackrNewsController()])
        window?.makeKeyAndVisible()
    }

    func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .default))
    }

    private func makeTabBarViewController(with controllers: [UIViewController]) {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = controllers
        window?.rootViewController = tabBarController
    }

    private func makeLiveHackrNewsController() -> LiveHackrNewsViewController {
        let httpClient = makeRemoteClient()
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: url, client: httpClient)
        let hackrStoryLoader = RemoteHackrStoryLoader(client: httpClient)
        return LiveHackrNewsUIComposer.composeWith(liveHackrNewsloader: liveHackrNewsloader, hackrStoryLoader: hackrStoryLoader)
    }
}
