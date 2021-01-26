//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

extension HackrNewsFeedUIIntegrationTests {
    class HackerNewsFeedLoaderSpy: HackrNewsFeedLoader, HackrStoryLoader {
        var completions = [(HackrNewsFeedLoader.Result) -> Void]()
        var loadCallCount: Int { completions.count }

        func load(completion: @escaping (HackrNewsFeedLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeHackrNewsFeedLoading(with news: [HackrNew] = [], at index: Int = 0) {
            completions[index](.success(news))
        }

        func completeHackrNewsFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            completions[index](.failure(error))
        }

        // MARK: - HackrStoryLoader

        var cancelledStoryUrls = 0
        var storiesRequests = [(HackrStoryLoader.Result) -> Void]()
        var storiesRequestsCallCount: Int { storiesRequests.count }

        private struct TaskSpy: HackrStoryLoaderTask {
            let cancellCallback: () -> Void

            func cancel() {
                cancellCallback()
            }
        }

        func load(completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
            storiesRequests.append(completion)
            return TaskSpy { [weak self] in self?.cancelledStoryUrls += 1 }
        }

        func completeStoryLoading(with story: Story = Story.any, at index: Int = 0) {
            storiesRequests[index](.success(story))
        }

        func completeStoryLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            storiesRequests[index](.failure(error))
        }
    }
}
