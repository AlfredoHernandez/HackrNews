//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

class FeedLoaderStub: HackrNewsFeedLoader {
    private let result: HackrNewsFeedLoader.Result

    init(_ result: HackrNewsFeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (HackrNewsFeedLoader.Result) -> Void) {
        completion(result)
    }
}
