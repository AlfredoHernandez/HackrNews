//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

enum LHNEndpoint {
    case newStories
    case topStories

    func url() -> URL {
        switch self {
        case .newStories:
            return URL(string: "https://hacker-news.firebaseio.com/v0/newstories.json")!
        case .topStories:
            return URL(string: "https://hacker-news.firebaseio.com/v0/topstories.json")!
        }
    }
}
