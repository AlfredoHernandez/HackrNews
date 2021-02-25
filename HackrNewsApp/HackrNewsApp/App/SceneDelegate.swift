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
    var previousViewController: UIViewController?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: HackrNewsStoryStore = {
        RealmHackrNewsStoryStore()
    }()

    convenience init(httpClient: HTTPClient, store: HackrNewsStoryStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
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

    private func commentLoader(for comment: Int) -> CommentLoader {
        RemoteLoader(
            url: Endpoint.item(comment).url(baseUrl),
            client: httpClient,
            mapper: StoryCommentMapper.map
        )
    }

    private func hackrStoryLoader(id: Int) -> HackrStoryLoader {
        let local = LocalHackrStoryLoader(store: store, currentDate: Date.init)
        let remote = RemoteLoader(url: Endpoint.item(id).url(baseUrl), client: httpClient, mapper: StoryItemMapper.map)
        local.validate(cacheforStory: id, completion: { _ in })
        return HackrStoryLoaderWithFallbackComposite(
            primary: local,
            fallback: HackrStoryLoaderCacheDecorator(
                decoratee: MainQueueDispatchDecorator(remote),
                cache: local
            )
        )
    }
}

extension SceneDelegate: UITabBarControllerDelegate {
    func tabBarController(_: UITabBarController, didSelect viewController: UIViewController) {
        if previousViewController == (viewController as? UINavigationController)?.topViewController as? HackrNewsFeedViewController {
            if let viewController = (viewController as? UINavigationController)?.topViewController as? HackrNewsFeedViewController {
                viewController.scrollToTop()
            }
        }
        previousViewController = viewController
    }

    func tabBarController(_: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        previousViewController = (viewController as? UINavigationController)?.topViewController
        return true
    }
}
