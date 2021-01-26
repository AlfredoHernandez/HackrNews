//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

extension MainQueueDispatchDecorator: HackrNewsFeedLoader where T == HackrNewsFeedLoader {
    func load(completion: @escaping (HackrNewsFeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: HackrStoryLoader where T == HackrStoryLoader {
    func load(completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
