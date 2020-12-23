//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        true
    }

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)

        #if DEBUG
        configuration.delegateClass = DebuggingSceneDelegate.self
        #endif

        return configuration
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {}
}
