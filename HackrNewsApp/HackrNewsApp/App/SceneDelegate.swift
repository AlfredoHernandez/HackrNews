//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import HackrNews
import HackrNewsiOS
import SafariServices
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let baseUrl = Endpoint.baseUrl
    var previousViewController: UIViewController?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
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
        UIBarButtonItem.appearance().tintColor = .hackrNews
        window?.makeKeyAndVisible()
    }

    private func makeTabBarViewController(with controllers: [UIViewController]) -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = UIColor.hackrNews
        tabBarController.viewControllers = controllers
        tabBarController.delegate = self
        return tabBarController
    }

    private func stories(for contentType: ContentType, withURL url: URL) -> UINavigationController {
        let hackrNewsFeedloader = httpClient.getPublisher(from: url).tryMap(HackrNewsFeedMapper.map).eraseToAnyPublisher()

        return UINavigationController(
            rootViewController: HackrNewsFeedUIComposer.composeWith(
                contentType: contentType,
                hackrNewsFeedloader: { hackrNewsFeedloader },
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
            title: model.title,
            text: model.text,
            author: model.author,
            score: model.score,
            createdAt: model.createdAt,
            totalComments: model.totalComments,
            comments: model.comments,
            url: model.url
        )
        let controller = StoryDetailsUIComposer.composeWith(model: storyDetail, didSelectStory: { [weak self] in
            guard let url = model.url else { return }
            self?.openOnSafari(with: url)
        }, loader: commentLoader)
        (tabBarController.selectedViewController as? UINavigationController)?.pushViewController(controller, animated: true)
    }

    private func commentLoader(for comment: Int) -> AnyPublisher<StoryComment, Error> {
        httpClient.getPublisher(from: Endpoint.item(comment).url(baseUrl)).tryMap(StoryCommentMapper.map).eraseToAnyPublisher()
    }

    private func hackrStoryLoader(id: Int) -> HackrStoryLoader {
        RemoteLoader(url: Endpoint.item(id).url(baseUrl), client: httpClient, mapper: StoryItemMapper.map)
    }
}

extension SceneDelegate: UITabBarControllerDelegate {
    func tabBarController(_: UITabBarController, didSelect viewController: UIViewController) {
        let topViewController = (viewController as? UINavigationController)?.topViewController
        if previousViewController == topViewController {
            if let viewController = topViewController as? HackrNewsFeedViewController {
                viewController.scrollToTop()
            }
        }
        previousViewController = viewController
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect _: UIViewController) -> Bool {
        previousViewController = (tabBarController.selectedViewController as? UINavigationController)?.topViewController
        return true
    }
}
