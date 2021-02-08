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
        score: 0,
        createdAt: Date(),
        totalComments: 0,
        comments: [],
        type: "story",
        url: URL(string: "https://any-url.com")!
    )
}
