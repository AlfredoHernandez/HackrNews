//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

class InMemoryFeedStore: HackrNewsStoryStore {
    var stories: [Int: (LocalStory, Date)] = [:]

    private init(cache: [Int: (LocalStory, Date)]) {
        stories = cache
    }

    static var empty: InMemoryFeedStore {
        InMemoryFeedStore(cache: [:])
    }

    static var withExpiredCache: InMemoryFeedStore {
        InMemoryFeedStore(
            cache: [
                1: (Story.any.toLocal(), Date.distantPast),
                2: (Story.any.toLocal(), Date.distantPast),
            ]
        )
    }

    static var withNonExpiredCache: InMemoryFeedStore {
        InMemoryFeedStore(
            cache: [
                1: (Story.any.toLocal(), Date()),
                2: (Story.any.toLocal(), Date()),
            ]
        )
    }

    func delete(storyID: Int, completion: @escaping DeletionCompletion) {
        stories.removeValue(forKey: storyID)
        completion(.success(()))
    }

    func insert(story: LocalStory, timestamp: Date, completion: @escaping InsertionCompletion) {
        stories[story.id] = (story, timestamp)
        completion(.success(()))
    }

    func retrieve(storyID: Int, completion: @escaping RetrievalCompletion) {
        guard let story = stories[storyID] else {
            return completion(.failure(anyNSError()))
        }
        completion(.success(story))
    }
}
