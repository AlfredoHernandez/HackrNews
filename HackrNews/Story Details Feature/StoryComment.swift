//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryComment: Equatable {
    public let id: Int
    public let author: String
    public let comments: [Int]
    public let parent: Int
    public let text: String
    public let createdAt: Date
    public let type: String

    public init(id: Int, author: String, comments: [Int], parent: Int, text: String, createdAt: Date, type: String) {
        self.id = id
        self.author = author
        self.comments = comments
        self.parent = parent
        self.text = text
        self.createdAt = createdAt
        self.type = type
    }
}
