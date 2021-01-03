//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

enum LHNEndpoint {
    case newStories
    case topStories
    case item(Int)

    static let baseUrl = URL(string: "https://hacker-news.firebaseio.com")!

    func url(_ baseURL: URL) -> URL {
        switch self {
        case .newStories:
            return baseURL.appendingPathComponent("/v0/newstories.json")
        case .topStories:
            return baseURL.appendingPathComponent("/v0/topstories.json")
        case let .item(id):
            return baseURL.appendingPathComponent("/v0/item/\(id).json")
        }
    }
}
