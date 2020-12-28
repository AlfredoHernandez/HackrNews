//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

extension LiveHackrNewsUIIntegrationTests {
    class LiveHackerNewLoaderSpy: LiveHackrNewsLoader, HackrStoryLoader {
        var completions = [(LiveHackrNewsLoader.Result) -> Void]()
        var loadCallCount: Int { completions.count }

        func load(completion: @escaping (LiveHackrNewsLoader.Result) -> Void) {
            completions.append(completion)
        }

        func completeLiveHackrNewsLoading(with news: [LiveHackrNew] = [], at index: Int = 0) {
            completions[index](.success(news))
        }

        func completeLiveHackrNewsLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            completions[index](.failure(error))
        }

        // MARK: - HackrStoryLoader

        var loadedStoryUrls: [URL] {
            storiesRequests.map(\.url)
        }

        var cancelledStoryUrls = [URL]()
        var storiesRequests = [(url: URL, completion: (HackrStoryLoader.Result) -> Void)]()

        private struct TaskSpy: HackrStoryLoaderTask {
            let cancellCallback: () -> Void

            func cancel() {
                cancellCallback()
            }
        }

        func load(from url: URL, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
            storiesRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledStoryUrls.append(url) }
        }

        func completeStoryLoading(with story: Story = Story.any, at index: Int = 0) {
            storiesRequests[index].completion(.success(story))
        }

        func completeStoryLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            storiesRequests[index].completion(.failure(error))
        }
    }
}
