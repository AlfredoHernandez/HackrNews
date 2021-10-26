//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import HackrNews

class HackrNewsFeedLoaderSpy {
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
    var storiesRequests = [PassthroughSubject<Story, Error>]()
    var storiesRequestsCallCount: Int { storiesRequests.count }

    func publisher() -> AnyPublisher<Story, Error> {
        let publisher = PassthroughSubject<Story, Error>()
        storiesRequests.append(publisher)
        return publisher
            .handleEvents(receiveCancel: { [weak self] in self?.cancelledStoryUrls += 1 })
            .eraseToAnyPublisher()
    }

    func completeStoryLoading(with story: Story = Story.any, at index: Int = 0) {
        storiesRequests[index].send(story)
        storiesRequests[index].send(completion: .finished)
    }

    func completeStoryLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        storiesRequests[index].send(completion: .failure(error))
    }
}
