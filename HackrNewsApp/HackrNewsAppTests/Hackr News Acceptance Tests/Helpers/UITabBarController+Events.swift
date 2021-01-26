//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNewsiOS
import UIKit

extension UITabBarController {
    var firstViewController: HackrNewsFeedViewController {
        let navigationController = viewControllers?.first as! UINavigationController
        let storiesViewController = navigationController.topViewController as! HackrNewsFeedViewController
        return storiesViewController
    }
}

extension UIViewController {
    private func simulateTap(at index: Int = 0) -> UIViewController? {
        if tabBarController!.viewControllers!.count < index { return nil }
        tabBarController!.selectedIndex = index
        return tabBarController!.selectedViewController
    }

    func simulateTapOnTopStories() -> HackrNewsFeedViewController {
        let navigation = simulateTap(at: topStoriesTab) as! UINavigationController
        return navigation.topViewController as! HackrNewsFeedViewController
    }

    func simulateTapOnNewStories() -> HackrNewsFeedViewController {
        let navigation = simulateTap(at: newStoriesTab) as! UINavigationController
        return navigation.topViewController as! HackrNewsFeedViewController
    }

    func simulateTapOnBestStories() -> HackrNewsFeedViewController {
        let navigation = simulateTap(at: bestStoriesTab) as! UINavigationController
        return navigation.topViewController as! HackrNewsFeedViewController
    }

    private var topStoriesTab: Int { 0 }

    private var newStoriesTab: Int { 1 }

    private var bestStoriesTab: Int { 2 }
}
