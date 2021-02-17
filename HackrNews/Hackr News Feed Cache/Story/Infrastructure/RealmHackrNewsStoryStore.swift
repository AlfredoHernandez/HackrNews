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
        let realmStory = realm.object(ofType: RealmStory.self, forPrimaryKey: storyID)
        guard let story = realmStory else {
            return completion(.success(nil))
        }
        completion(.success(story.toLocal()))
    }

    public func insert(story: LocalStory, completion: @escaping InsertionCompletion) {
        do {
            try realm.write {
                realm.add(story.toRealm())
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }

    public func delete(_: LocalStory, completion _: @escaping DeletionCompletion) {}
}
