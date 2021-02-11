//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum StoryCommentMapper {
    struct Root: Decodable {
        let id: Int
        let deleted: Bool?
        let by: String?
        let kids: [Int]?
        let parent: Int
        let text: String?
        let time: Date
        let type: String
    }

    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(data: Data, response: HTTPURLResponse) throws -> StoryComment {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        guard response.isOK, let item = try? decoder.decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return StoryComment(
            id: item.id,
            deleted: item.deleted ?? false,
            author: item.by,
            comments: item.kids ?? [],
            parent: item.parent,
            text: item.text,
            createdAt: item.time,
            type: item.type
        )
    }
}
