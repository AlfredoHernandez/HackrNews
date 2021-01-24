//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum HackrNewsFeedMapper {
    typealias LiveItem = Int

    public static func map(data: Data, response: HTTPURLResponse) throws -> [LiveHackrNew] {
        guard response.isOK, let data = try? JSONDecoder().decode([LiveItem].self, from: data) else {
            throw RemoteLiveHackrNewsLoader.Error.invalidData
        }
        return data.map { LiveHackrNew(id: $0) }
    }
}
