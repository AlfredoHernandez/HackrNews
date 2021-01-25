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
        let liveHackrNewsloader = RemoteLoader(url: url, client: httpClient, mapper: HackrNewsFeedMapper.map)
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
        RemoteLoader(url: LHNEndpoint.item(id).url(baseUrl), client: httpClient, mapper: StoryItemMapper.map)
    }
}

// MARK: - Live Hackr News Loader

extension RemoteLoader: LiveHackrNewsLoader where Resource == [LiveHackrNew] {
    public func load(completion: @escaping (Result) -> Void) {
        let _: HTTPClientTask = load(completion: completion)
    }
}

// MARK: - Hackr Story Loader

extension RemoteLoader: HackrStoryLoader where Resource == Story {
    class TaskWrapper: HackrStoryLoaderTask {
        private let task: HTTPClientTask

        init(task: HTTPClientTask) {
            self.task = task
        }

        func cancel() {
            task.cancel()
        }
    }

    public func load(completion: @escaping (Result) -> Void) -> HackrStoryLoaderTask {
        TaskWrapper(task: load(completion: completion))
    }
}
