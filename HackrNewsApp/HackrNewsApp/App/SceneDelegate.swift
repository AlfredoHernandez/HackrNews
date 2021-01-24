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

    private lazy var tabBarController: UITabBarController = makeTabBarViewController(
        with: [
            stories(for: .topStories, withURL: LHNEndpoint.topStories.url(baseUrl)),
            stories(for: .newStories, withURL: LHNEndpoint.newStories.url(baseUrl)),
            stories(for: .bestStories, withURL: LHNEndpoint.bestStories.url(baseUrl)),
        ]
    )

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
        tabBarController.tabBar.tintColor = UIColor.hackerNews
        tabBarController.viewControllers = controllers
        return tabBarController
    }

    private func stories(for contentType: ContentType, withURL url: URL) -> UINavigationController {
        let liveHackrNewsloader = RemoteLiveHackrNewsLoader(url: url, client: httpClient)
        return UINavigationController(
            rootViewController: LiveHackrNewsUIComposer.composeWith(
                contentType: contentType,
                liveHackrNewsloader: liveHackrNewsloader,
                hackrStoryLoader: hackrStoryLoader,
                didSelectStory: openOnSafari
            )
        )
    }

    private func openOnSafari(with url: URL) {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = UIColor.hackerNews
        tabBarController.present(controller, animated: true)
    }

    private func hackrStoryLoader(id: Int) -> HackrStoryLoader {
        RemoteHackrStoryLoader(url: LHNEndpoint.item(id).url(baseUrl), client: httpClient)
    }
}

// MARK: - Live Hackr News Loader

public typealias RemoteLiveHackrNewsLoader = RemoteLoader<[LiveHackrNew]>

public extension RemoteLiveHackrNewsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: HackrNewsFeedMapper.map)
    }
}

extension RemoteLiveHackrNewsLoader: LiveHackrNewsLoader where Resource == [LiveHackrNew] {}

// MARK: - Comment Loader

public typealias RemoteStoryCommentLoader = RemoteLoader<StoryComment>

public extension RemoteStoryCommentLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: StoryCommentMapper.map)
    }
}
