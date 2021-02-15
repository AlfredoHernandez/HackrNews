//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol HackrNewsStoryStore {
    typealias DeletionResult = Swift.Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Swift.Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Swift.Result<LocalStory?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    func delete(_ story: LocalStory, completion: @escaping DeletionCompletion)
    func insert(story: LocalStory, with timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}

public struct LocalStory: Equatable {
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
