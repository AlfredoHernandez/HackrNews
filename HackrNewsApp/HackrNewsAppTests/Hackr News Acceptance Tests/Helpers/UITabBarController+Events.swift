//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNewsiOS
import UIKit

extension UITabBarController {
    var firstViewController: LiveHackrNewsViewController {
        let navigationController = viewControllers?.first as! UINavigationController
        let storiesViewController = navigationController.topViewController as! LiveHackrNewsViewController
        return storiesViewController
    }
}

extension UIViewController {
    private func simulateTap(at index: Int = 0) -> UIViewController? {
        if tabBarController!.viewControllers!.count < index { return nil }
        tabBarController!.selectedIndex = index
        return tabBarController!.selectedViewController
    }

    func simulateTapOnNewStories() -> LiveHackrNewsViewController {
        let navigation = simulateTap(at: newStoriesTab) as! UINavigationController
        return navigation.topViewController as! LiveHackrNewsViewController
    }

    private var newStoriesTab: Int { 1 }
}
