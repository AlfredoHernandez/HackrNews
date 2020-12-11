//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum LiveDataMapper {
    public typealias LiveItem = Int

    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(data: Data, response: HTTPURLResponse) throws -> [LiveHackerNew] {
        guard response.isOK, let data = try? JSONDecoder().decode([LiveItem].self, from: data) else {
            throw Error.invalidData
        }
        return data
    }
}
