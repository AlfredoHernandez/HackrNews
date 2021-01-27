//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct Story: Equatable {
    public let id: Int
    public let title: String?
    public let text: String?
    public let author: String
    public let score: Int?
    public let createdAt: Date
    public let totalComments: Int?
    public let comments: [Int]?
    public let type: String
    public let url: URL?

    public init(
        id: Int,
        title: String?,
        text: String?,
        author: String,
        score: Int?,
        createdAt: Date,
        totalComments: Int?,
        comments: [Int]?,
        type: String,
        url: URL?
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.author = author
        self.score = score
        self.createdAt = createdAt
        self.totalComments = totalComments
        self.comments = comments
        self.type = type
        self.url = url
    }
}
