//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct Story {
    public let id: Int
    public let title: String
    public let author: String
    public let score: Int
    public let createdAt: Date
    public let totalComments: Int
    public let comments: Int
    public let type: String
    public let url: URL
}
