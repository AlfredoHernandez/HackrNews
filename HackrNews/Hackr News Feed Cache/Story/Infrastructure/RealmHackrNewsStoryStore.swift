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

    public func insert(story: LocalStory, completion: @escaping InsertionCompletion) {
        do {
            try write { realm in
                realm.add(story.toRealm(), update: .modified)
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

    private func retrieve(storyWithID id: Int) -> RealmStory? {
        realm.object(ofType: RealmStory.self, forPrimaryKey: id)
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
