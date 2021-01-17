//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import SafariServices
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let baseUrl = LHNEndpoint.baseUrl

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .default))
    }()

    convenience init(httpClient: HTTPClient) {
        self.init()
        self.httpClient = httpClient
    }

    private lazy var tabBarController: UITabBarController = makeTabBarViewController(with: [topStories(), newStories(), bestStories()])

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }

    func configureWindow() {
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    private func makeTabBarViewController(with controllers: [UIViewController]) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = UIColor.systemRed
        tabBarController.viewControllers = controllers
        return tabBarController
    }

    private func topStories() -> UINavigationController {
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: LHNEndpoint.topStories.url(baseUrl), client: httpClient)
        return UINavigationController(
            rootViewController: LiveHackrNewsUIComposer.composeWith(
                contentType: .topStories,
                liveHackrNewsloader: liveHackrNewsloader,
                hackrStoryLoader: hackrStoryLoader,
                didSelectStory: openOnSafari
            )
        )
    }

    private func newStories() -> UINavigationController {
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: LHNEndpoint.newStories.url(baseUrl), client: httpClient)
        return UINavigationController(
            rootViewController: LiveHackrNewsUIComposer.composeWith(
                contentType: .newStories,
                liveHackrNewsloader: liveHackrNewsloader,
                hackrStoryLoader: hackrStoryLoader,
                didSelectStory: openOnSafari
            )
        )
    }

    private func bestStories() -> UINavigationController {
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: LHNEndpoint.bestStories.url(baseUrl), client: httpClient)
        return UINavigationController(
            rootViewController: LiveHackrNewsUIComposer.composeWith(
                contentType: .bestStories,
                liveHackrNewsloader: liveHackrNewsloader,
                hackrStoryLoader: hackrStoryLoader,
                didSelectStory: openOnSafari
            )
        )
    }

    private func openOnSafari(with url: URL) {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = .systemRed
        tabBarController.present(controller, animated: true)
    }

    private func hackrStoryLoader(id: Int) -> HackrStoryLoader {
        RemoteHackrStoryLoader(url: LHNEndpoint.item(id).url(baseUrl), client: httpClient)
    }
}
