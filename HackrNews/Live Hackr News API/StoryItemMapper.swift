//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

struct StoryItemMapper {
    struct Item: Decodable {
        let id: Int
        let title: String
        let by: String
        let score: Int
        let time: Date
        let descendants: Int
        let kids: [Int]
        let type: String
        let url: URL
    }

    static func map(data: Data, response: HTTPURLResponse) throws -> Item {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        guard response.isOK, let item = try? decoder.decode(Item.self, from: data) else {
            throw RemoteHackrStoryLoader.Error.invalidData
        }
        return item
    }
}
