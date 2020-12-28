//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

enum LHNEndpoint {
    case newStories

    func url() -> URL {
        switch self {
        case .newStories:
            return URL(string: "https://hacker-news.firebaseio.com/v0/newstories.json")!
        }
    }
}
