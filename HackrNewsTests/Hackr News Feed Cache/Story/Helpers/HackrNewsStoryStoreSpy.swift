//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

class HackrNewsStoryStoreSpy: HackrNewsStoryStore {
    enum Message: Equatable {
        case deletion(LocalStory)
        case insertion(LocalStory)
        case retrieve(storyID: Int)
    }

    private(set) var receivedMessages = [Message]()
    private(set) var deletionCompletions = [DeletionCompletion]()

    func delete(_ story: LocalStory, completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deletion(story))
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }

    private(set) var insertionCompletions = [InsertionCompletion]()

    func insert(story: LocalStory, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insertion(story))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }

    private(set) var retrievalCompletions = [RetrievalCompletion]()

    func retrieve(storyID: Int, completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve(storyID: storyID))
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(nil))
    }

    func completeRetrieval(with story: LocalStory, at index: Int = 0) {
        retrievalCompletions[index](.success(story))
    }
}
