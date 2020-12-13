//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum LiveDataMapper {
    public typealias LiveItem = Int

    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(data: Data, response: HTTPURLResponse) throws -> [LiveHackrNew] {
        guard response.isOK, let data = try? JSONDecoder().decode([LiveItem].self, from: data) else {
            throw Error.invalidData
        }
        return data.map {
            LiveHackrNew(
                id: $0,
                url: URL(string: "https://hacker-news.firebaseio.com/v0/item/\($0).json")!
            )
        }
    }
}
