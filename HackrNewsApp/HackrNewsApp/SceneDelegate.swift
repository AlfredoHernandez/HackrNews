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

    private lazy var navigationController: UINavigationController = {
        UINavigationController(rootViewController: makeTopStoriesController())
    }()

    private lazy var newStoriesNavigationController: UINavigationController = {
        UINavigationController(rootViewController: makeNewStoriesController())
    }()

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }

    func configureWindow() {
        let tabBarController = makeTabBarViewController(with: [navigationController, newStoriesNavigationController])
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    private func makeTabBarViewController(with controllers: [UIViewController]) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = UIColor.systemRed
        tabBarController.viewControllers = controllers
        return tabBarController
    }

    private func makeTopStoriesController() -> LiveHackrNewsViewController {
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: LHNEndpoint.topStories.url(baseUrl), client: httpClient)
        return LiveHackrNewsUIComposer.composeWith(
            contentType: .topStories,
            liveHackrNewsloader: liveHackrNewsloader,
            hackrStoryLoader: hackrStoryLoader,
            didSelectStory: openOnSafari
        )
    }

    private func makeNewStoriesController() -> LiveHackrNewsViewController {
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: LHNEndpoint.newStories.url(baseUrl), client: httpClient)
        let controller = LiveHackrNewsUIComposer.composeWith(
            contentType: .newStories,
            liveHackrNewsloader: liveHackrNewsloader,
            hackrStoryLoader: hackrStoryLoader,
            didSelectStory: openOnSafari
        )
        return controller
    }

    private func openOnSafari(with url: URL) {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = .systemRed
        navigationController.present(controller, animated: true)
    }

    private func hackrStoryLoader(id: Int) -> HackrStoryLoader {
        RemoteHackrStoryLoader(url: LHNEndpoint.item(id).url(baseUrl), client: httpClient)
    }
}
