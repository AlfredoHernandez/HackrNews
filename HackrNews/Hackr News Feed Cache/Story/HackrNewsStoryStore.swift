//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct CachedStory {
    public let story: LocalStory
    public let timestamp: Date

    public init(story: LocalStory, timestamp: Date) {
        self.story = story
        self.timestamp = timestamp
    }
}

public protocol HackrNewsStoryStore {
    typealias DeletionResult = Swift.Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Swift.Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Swift.Result<CachedStory?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    func delete(_ story: LocalStory, completion: @escaping DeletionCompletion)
    func insert(story: LocalStory, with timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(storyID: Int, completion: @escaping RetrievalCompletion)
}
