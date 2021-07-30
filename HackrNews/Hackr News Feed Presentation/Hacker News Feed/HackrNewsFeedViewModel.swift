//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct HackrNewsFeedViewModel {
    public let stories: [HackrNew]

    public init(stories: [HackrNew]) {
        self.stories = stories
    }
}
