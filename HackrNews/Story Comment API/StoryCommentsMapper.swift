//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum StoryCommentsMapper {
    struct Root: Decodable {
        let id: Int
        let by: String
        let kids: [Int]
        let parent: Int
        let text: String
        let time: Date
        let type: String
    }

    public static func map(data: Data, response: HTTPURLResponse) throws -> StoryComment {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        guard response.isOK, let item = try? decoder.decode(Root.self, from: data) else {
            throw RemoteStoryCommentLoader.Error.invalidData
        }
        return StoryComment(
            id: item.id,
            author: item.by,
            comments: item.kids,
            parent: item.parent,
            text: item.text,
            createdAt: item.time,
            type: item.type
        )
    }
}