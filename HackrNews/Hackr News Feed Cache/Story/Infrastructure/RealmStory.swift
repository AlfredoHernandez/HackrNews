//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import RealmSwift

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

    private func validateURL(_ storyURL: String?) -> URL? {
        guard let stringURL = storyURL else { return nil }
        return URL(string: stringURL)
    }

    func toLocal() -> LocalStory {
        let url: URL? = validateURL(self.url)
        return LocalStory(
            id: id,
            title: title,
            text: text,
            author: author,
            score: score.value,
            createdAt: createdAt,
            totalComments: totalComments.value,
            comments: comments.count > 0 ? comments.map(\.id) : nil,
            type: type,
            url: url
        )
    }
}

extension LocalStory {
    func toRealm() -> RealmStory {
        let realmCommentsList = List<CommentID>()
        if let comments = comments {
            if comments.count > 0 {
                let realmComments = comments.toCommentID()
                realmComments.forEach { realmCommentsList.append($0) }
            }
        }
        return RealmStory(
            id: id,
            title: title,
            text: text,
            author: author,
            score: score,
            createdAt: createdAt,
            totalComments: totalComments,
            comments: realmCommentsList,
            type: type,
            url: url?.absoluteString
        )
    }
}

private extension Array where Element == Int {
    func toCommentID() -> [CommentID] {
        map { CommentID(value: [$0]) }
    }
}
