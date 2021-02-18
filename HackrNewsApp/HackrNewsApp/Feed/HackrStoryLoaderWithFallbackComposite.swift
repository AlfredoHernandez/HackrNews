//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

class HackrStoryLoaderWithFallbackComposite: HackrStoryLoader {
    private let primary: HackrStoryLoader
    private let fallback: HackrStoryLoader

    init(primary: HackrStoryLoader, fallback: HackrStoryLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    class TaskWrapper: HackrStoryLoaderTask {
        var wrapped: HackrStoryLoaderTask?

        func cancel() {
            wrapped?.cancel()
        }
    }

    func load(id: Int, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
        let task = TaskWrapper()
        task.wrapped = primary.load(id: id) { [weak self] result in
            switch result {
            case let .success(story):
                completion(.success(story))
            case .failure:
                task.wrapped = self?.fallback.load(id: id, completion: completion)
            }
        }
        return task
    }
}
