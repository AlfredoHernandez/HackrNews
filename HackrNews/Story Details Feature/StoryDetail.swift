//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryDetail {
    public let title: String?
    public let text: String?
    public let author: String
    public let score: Int?
    public let createdAt: Date
    public let totalComments: Int?
    public let comments: [Int]?
    public let url: URL?

    public init(
        title: String?,
        text: String?,
        author: String,
        score: Int?,
        createdAt: Date,
        totalComments: Int?,
        comments: [Int]?,
        url: URL?
    ) {
        self.title = title
        self.text = text
        self.author = author
        self.score = score
        self.createdAt = createdAt
        self.totalComments = totalComments
        self.comments = comments
        self.url = url
    }

    public var hasBody: Bool {
        text != nil
    }
}
