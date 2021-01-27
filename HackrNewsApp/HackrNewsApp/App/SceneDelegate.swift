//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import SafariServices
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let baseUrl = Endpoint.baseUrl

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .default))
    }()

    convenience init(httpClient: HTTPClient) {
        self.init()
        self.httpClient = httpClient
    }

    private lazy var tabBarController: UITabBarController = makeTabBarViewController(
        with: [
            stories(for: .topStories, withURL: Endpoint.topStories.url(baseUrl)),
            stories(for: .newStories, withURL: Endpoint.newStories.url(baseUrl)),
            stories(for: .bestStories, withURL: Endpoint.bestStories.url(baseUrl)),
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
        tabBarController.tabBar.tintColor = UIColor.hackrNews
        tabBarController.viewControllers = controllers
        return tabBarController
    }

    private func stories(for contentType: ContentType, withURL url: URL) -> UINavigationController {
        let hackrNewsFeedloader = RemoteLoader(url: url, client: httpClient, mapper: HackrNewsFeedMapper.map)
        return UINavigationController(
            rootViewController: HackrNewsFeedUIComposer.composeWith(
                contentType: contentType,
                hackrNewsFeedloader: hackrNewsFeedloader,
                hackrStoryLoader: hackrStoryLoader,
                didSelectStory: details
            )
        )
    }

    private func openOnSafari(with url: URL) {
        let controller = SFSafariViewController(url: url)
        controller.preferredControlTintColor = UIColor.hackrNews
        tabBarController.present(controller, animated: true)
    }

    private func details(with model: Story) {
        let storyDetail = StoryDetail(
            title: model.title ?? "",
            text: model.text,
            author: model.author,
            score: model.score ?? 0,
            createdAt: model.createdAt,
            totalComments: model.totalComments ?? 0,
            comments: model.comments ?? [],
            url: model.url
        )
        let controller = StoryDetailsUIComposer.composeWith(model: storyDetail)
        (tabBarController.selectedViewController as? UINavigationController)?.pushViewController(controller, animated: true)
    }

    private func hackrStoryLoader(id: Int) -> HackrStoryLoader {
        RemoteLoader(url: Endpoint.item(id).url(baseUrl), client: httpClient, mapper: StoryItemMapper.map)
    }
}
