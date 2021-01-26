//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

// MARK: - Hackr News Feed Loader

extension RemoteLoader: HackrNewsFeedLoader where Resource == [HackrNew] {
    public func load(completion: @escaping (Result) -> Void) {
        let _: HTTPClientTask = load(completion: completion)
    }
}

// MARK: - Hackr Story Loader

extension RemoteLoader: HackrStoryLoader where Resource == Story {
    class TaskWrapper: HackrStoryLoaderTask {
        private let task: HTTPClientTask

        init(task: HTTPClientTask) {
            self.task = task
        }

        func cancel() {
            task.cancel()
        }
    }

    public func load(completion: @escaping (Result) -> Void) -> HackrStoryLoaderTask {
        TaskWrapper(task: load(completion: completion))
    }
}
