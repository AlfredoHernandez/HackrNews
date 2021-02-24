//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNewsiOS
import UIKit

extension HackrNewsFeedViewController {
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

    func simulateTapOnTabItem() {
        navigationController?.tabBarController?.simulateTap(at: navigationController!)
    }
}
