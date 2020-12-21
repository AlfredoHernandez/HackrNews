//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct LiveHackrNew: Equatable {
    public let id: Int
    public let url: URL

    public init(id: Int, url: URL) {
        self.id = id
        self.url = url
    }
}
