//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

// MARK: - Hackr Story Loader

extension RemoteLoader: HackrStoryLoader where Resource == Story {
    private class TaskWrapper: HackrStoryLoaderTask {
        private let task: HTTPClientTask

        init(task: HTTPClientTask) {
            self.task = task
        }

        func cancel() {
            task.cancel()
        }
    }

    public func load(id _: Int, completion: @escaping (Result) -> Void) -> HackrStoryLoaderTask {
        TaskWrapper(task: load(completion: completion))
    }
}
