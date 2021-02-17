//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import RealmSwift

public final class RealmHackrNewsStoryStore {
    public typealias RetrievalResult = Swift.Result<LocalStory?, Error>
    public typealias RetrievalCompletion = (RetrievalResult) -> Void

    public typealias InsertionResult = Swift.Result<Void, Error>
    public typealias InsertionCompletion = (InsertionResult) -> Void

    private let realm: Realm

    public init() {
        realm = try! Realm()
    }

    public func retrieve(storyID: Int, completion: @escaping RetrievalCompletion) {
        let realmStory = realm.object(ofType: RealmStory.self, forPrimaryKey: storyID)
        guard let story = realmStory else {
            return completion(.success(nil))
        }

        var url: URL?
        if let stringURL = story.url {
            url = URL(string: stringURL)
        }

        let local = LocalStory(
            id: story.id,
            title: story.title,
            text: story.text,
            author: story.author,
            score: story.score.value,
            createdAt: story.createdAt,
            totalComments: story.totalComments.value,
            comments: story.comments.map(\.id),
            type: story.type,
            url: url
        )
        completion(.success(local))
    }

    public func insert(story: LocalStory, completion: @escaping InsertionCompletion) {
        do {
            try realm.write {
                let realmComments = story.comments?.map { value in
                    CommentID(value: [value])
                }
                let realmCommentsList = List<CommentID>()
                realmComments?.forEach { comment in
                    realmCommentsList.append(comment)
                }
                let realmStory = RealmStory(
                    id: story.id,
                    title: story.title,
                    text: story.text,
                    author: story.author,
                    score: story.score,
                    createdAt: story.createdAt,
                    totalComments: story.totalComments,
                    comments: realmCommentsList,
                    type: story.type,
                    url: story.url?.absoluteString
                )
                realm.add(realmStory)
                completion(.success(()))
            }
        } catch {
            completion(.failure(error))
        }
    }
}

class RealmStory: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var title: String?
    @objc dynamic var text: String?
    @objc dynamic var author: String = ""
    var score = RealmOptional<Int>()
    @objc dynamic var createdAt = Date()
    var totalComments = RealmOptional<Int>()
    var comments = List<CommentID>()
    @objc dynamic var type: String = ""
    @objc dynamic var url: String?

    override class func primaryKey() -> String? {
        "id"
    }

    convenience init(
        id: Int = 0,
        title: String? = nil,
        text: String? = nil,
        author: String = "",
        score: Int? = nil,
        createdAt: Date = Date(),
        totalComments: Int? = nil,
        comments: List<CommentID>,
        type: String = "",
        url: String? = nil
    ) {
        self.init()
        self.id = id
        self.title = title
        self.text = text
        self.author = author
        self.score = RealmOptional(score)
        self.createdAt = createdAt
        self.totalComments = RealmOptional(totalComments)
        self.comments = comments
        self.type = type
        self.url = url
    }
}

class CommentID: Object {
    @objc dynamic var id: Int = 0
}
