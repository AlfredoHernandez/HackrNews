//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum StoryCommentsMapper {
    public typealias LiveItem = Int

    public static func map(data: Data, response: HTTPURLResponse) throws -> [LiveItem] {
        guard response.isOK, let data = try? JSONDecoder().decode([LiveItem].self, from: data) else {
            throw RemoteStoryCommentsLoader.Error.invalidData
        }
        return data
    }
}
