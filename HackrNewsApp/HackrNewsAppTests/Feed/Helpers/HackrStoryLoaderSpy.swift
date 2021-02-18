//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

class HackrStoryLoaderSpy: HackrStoryLoader {
    var completions = [(id: Int, completion: (HackrStoryLoader.Result) -> Void)]()

    var loadedStories: [Int] { completions.map(\.id) }
    var cancelledStories = [Int]()

    class Task: HackrStoryLoaderTask {
        private let action: () -> Void

        init(_ action: @escaping () -> Void) {
            self.action = action
        }

        func cancel() {
            action()
        }
    }

    func load(id: Int, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
        completions.append((id, completion))
        return Task { [weak self] in
            self?.cancelledStories.append(id)
        }
    }

    func completes(with error: Error, at index: Int = 0) {
        completions[index].completion(.failure(error))
    }

    func completes(with story: Story, at index: Int = 0) {
        completions[index].completion(.success(story))
    }
}
