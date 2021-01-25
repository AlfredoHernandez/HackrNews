//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryItemMapper {
    private struct Item: Decodable {
        private let id: Int
        private let title: String?
        private let by: String
        private let score: Int?
        private let time: Date
        private let descendants: Int?
        private let kids: [Int]?
        private let type: String
        private let url: URL?

        var model: Story {
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

    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(data: Data, response: HTTPURLResponse) throws -> Story {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        guard response.isOK, let item = try? decoder.decode(Item.self, from: data) else {
            throw Error.invalidData
        }
        return item.model
    }
}
