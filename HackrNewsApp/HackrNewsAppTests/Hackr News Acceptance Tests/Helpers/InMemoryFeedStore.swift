//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

class InMemoryFeedStore: HackrNewsStoryStore {
    var stories: [Int: LocalStory] = [:]

    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }

    func delete(storyID: Int, completion: @escaping DeletionCompletion) {
        stories.removeValue(forKey: storyID)
        completion(.success(()))
    }

    func insert(story: LocalStory, completion: @escaping InsertionCompletion) {
        stories[story.id] = story
        completion(.success(()))
    }

    func retrieve(storyID: Int, completion: @escaping RetrievalCompletion) {
        guard let story = stories[storyID] else {
            return completion(.failure(anyNSError()))
        }
        completion(.success(story))
    }
}
