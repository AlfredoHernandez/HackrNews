//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import HackrNews

extension HackrNewsFeedUIIntegrationTests {
    class HackrNewsFeedLoaderSpy: HackrStoryLoader {
        var publishers = [PassthroughSubject<[HackrNew], Error>]()
        var loadCallCount: Int { publishers.count }

        func publisher() -> AnyPublisher<[HackrNew], Error> {
            let publisher = PassthroughSubject<[HackrNew], Error>()
            publishers.append(publisher)
            return publisher.eraseToAnyPublisher()
        }

        func completeHackrNewsFeedLoading(with news: [HackrNew] = [], at index: Int = 0) {
            publishers[index].send(news)
            publishers[index].send(completion: .finished)
        }

        func completeHackrNewsFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            publishers[index].send(completion: .failure(error))
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

        func load(id _: Int, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
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
