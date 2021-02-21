//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import RealmSwift

public final class RealmHackrNewsStoryStore: HackrNewsStoryStore {
    private let realm: Realm

    public init() {
        realm = try! Realm()
    }

    public func retrieve(storyID: Int, completion: @escaping RetrievalCompletion) {
        guard let cache = retrieve(storyWithID: storyID), let story = cache.story else {
            return completion(.success(nil))
        }
        let cachedStory = CachedStory(story.toLocal(), cache.timestamp)
        completion(.success(cachedStory))
    }

    public func insert(story: LocalStory, timestamp: Date, completion: @escaping InsertionCompletion) {
        do {
            try write { realm in
                let cache = RealmStoryCache(timestamp: timestamp, story: story.toRealm())
                realm.add(cache, update: .modified)
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }

    public func delete(storyID: Int, completion: @escaping DeletionCompletion) {
        if let story = retrieve(storyWithID: storyID) {
            do {
                try write { realm in
                    realm.delete(story)
                    completion(.success(()))
                }
            } catch {
                completion(.failure(error))
            }
        } else {
            completion(.success(()))
        }
    }

    private func retrieve(storyWithID id: Int) -> RealmStoryCache? {
        realm.object(ofType: RealmStoryCache.self, forPrimaryKey: id)
    }

    private func write(action: (Realm) -> Void) throws {
        let realm = self.realm
        try realm.safeWrite {
            action(realm)
        }
    }
}

public extension Realm {
    func safeWrite(_ block: () throws -> Void) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
