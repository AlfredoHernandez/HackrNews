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

    enum Error: Swift.Error {
        case storyAlreadyExists
    }

    public func insert(story: LocalStory, completion: @escaping InsertionCompletion) {
        let realmStory = realm.object(ofType: RealmStory.self, forPrimaryKey: story.id)
        if realmStory != nil {
            completion(.failure(Error.storyAlreadyExists))
        } else {
            do {
                try write { realm in
                    realm.add(story.toRealm(), update: .error)
                    completion(.success(()))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func delete(_: LocalStory, completion _: @escaping DeletionCompletion) {}

    private func write(action: (Realm) -> Void) throws {
        let realm = self.realm
        try realm.write {
            action(realm)
        }
    }
}
