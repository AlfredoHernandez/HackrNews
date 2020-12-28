//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

enum LHNEndpoint {
    case newStories
    case topStories

    static let baseUrl = URL(string: "https://hacker-news.firebaseio.com")!

    func url(_ baseURL: URL) -> URL {
        switch self {
        case .newStories:
            return baseURL.appendingPathComponent("/v0/newstories.json")
        case .topStories:
            return baseURL.appendingPathComponent("/v0/topstories.json")
        }
    }
}
