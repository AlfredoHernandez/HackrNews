//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol HackrNewsStoryStore {
    typealias DeletionResult = Swift.Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Swift.Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    func delete(_ story: Story, completion: @escaping DeletionCompletion)
    func insert(story: Story, with timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve()
}
