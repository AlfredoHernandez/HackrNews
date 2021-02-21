//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol HackrNewsStoryStore {
    typealias DeletionResult = Swift.Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Swift.Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Swift.Result<CachedStory?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    func delete(storyID: Int, completion: @escaping DeletionCompletion)

    func insert(story: LocalStory, timestamp: Date, completion: @escaping InsertionCompletion)

    func retrieve(storyID: Int, completion: @escaping RetrievalCompletion)
}
