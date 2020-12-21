//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum StoryItemMapper {
    enum Error: Swift.Error {
        case invalidData
    }

    private struct Item: Decodable {
        private let id: Int
        private let title: String
        private let by: String
        private let score: Int
        private let time: Date
        private let descendants: Int
        private let kids: [Int]
        private let type: String
        private let url: URL

        var story: Story {
            Story(
                id: id,
                title: title,
                author: by,
                score: score,
                createdAt: time,
                totalComments: descendants,
                comments: kids,
                type: type,
                url: url
            )
        }
    }

    public static func map(data: Data, response: HTTPURLResponse) throws -> Story {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        guard response.isOK, let item = try? decoder.decode(Item.self, from: data) else {
            throw Error.invalidData
        }
        return item.story
    }
}
