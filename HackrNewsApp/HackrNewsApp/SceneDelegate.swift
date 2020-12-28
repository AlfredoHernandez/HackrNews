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
        let tabBarController = makeTabBarViewController(with: [makeLiveHackrNewsController()])
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func makeRemoteClient() -> HTTPClient {
        URLSessionHTTPClient(session: URLSession(configuration: .default))
    }

    private func makeTabBarViewController(with controllers: [UIViewController]) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = UIColor.systemRed
        tabBarController.viewControllers = controllers
        return tabBarController
    }

    private func makeLiveHackrNewsController() -> UINavigationController {
        let httpClient = makeRemoteClient()
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: LHNEndpoint.newStories.url(), client: httpClient)
        let hackrStoryLoader = RemoteHackrStoryLoader(client: httpClient)
        let controller = LiveHackrNewsUIComposer.composeWith(liveHackrNewsloader: liveHackrNewsloader, hackrStoryLoader: hackrStoryLoader)
        let navigationController = UINavigationController(rootViewController: controller)
        return navigationController
    }
}
