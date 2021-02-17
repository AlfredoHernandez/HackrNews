//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

extension Story {
    static var any = Story(
        id: Int.random(in: 0 ... 100),
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

    static func uniqueStory() -> (model: Story, local: LocalStory) {
        let story = Story.any
        let local = story.toLocal()
        return (story, local)
    }
}
