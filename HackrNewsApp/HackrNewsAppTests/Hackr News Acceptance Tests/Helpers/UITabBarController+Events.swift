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

    func simulateTap(at controller: UIViewController) {
        delegate?.tabBarController?(self, didSelect: controller)
    }
}
