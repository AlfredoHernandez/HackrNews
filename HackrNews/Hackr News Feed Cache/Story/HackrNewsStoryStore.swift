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
    func insert(story: LocalStory, completion: @escaping InsertionCompletion)
    func retrieve(storyID: Int, completion: @escaping RetrievalCompletion)
}
