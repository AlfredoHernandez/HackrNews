//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum LiveDataMapper {
    public typealias LiveItem = Int

    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(data: Data, response: HTTPURLResponse) throws -> [LiveItem] {
        guard response.statusCode == 200, let data = try? JSONDecoder().decode([Int].self, from: data) else {
            throw Error.invalidData
        }
        return data
    }
}
