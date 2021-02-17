//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

extension Story {
    static func unique() -> (model: Story, local: LocalStory) {
        let story = Story(
            id: Int.random(in: 0 ... 1000),
            title: "a title",
            text: "a text",
            author: "a username",
            score: 10,
            createdAt: Date(),
            totalComments: 3,
            comments: [1, 2, 3],
            type: "story",
            url: URL(string: "https://any-url.com")!
        )
        let local = story.toLocal()
        return (story, local)
    }
}
