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
        guard let story = retrieve(storyWithID: storyID) else {
            return completion(.success(nil))
        }
        completion(.success(story.toLocal()))
    }

    enum Error: Swift.Error {
        case storyAlreadyExists
    }

    public func insert(story: LocalStory, completion: @escaping InsertionCompletion) {
        if retrieve(storyWithID: story.id) != nil {
            completion(.failure(Error.storyAlreadyExists))
        } else {
            insert(story, with: completion)
        }
    }

    public func delete(_: LocalStory, completion _: @escaping DeletionCompletion) {}

    private func retrieve(storyWithID id: Int) -> RealmStory? {
        realm.object(ofType: RealmStory.self, forPrimaryKey: id)
    }

    private func insert(_ story: LocalStory, with completion: RealmHackrNewsStoryStore.InsertionCompletion) {
        do {
            try write { realm in
                realm.add(story.toRealm(), update: .error)
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }

    private func write(action: (Realm) -> Void) throws {
        let realm = self.realm
        try realm.write {
            action(realm)
        }
    }
}
