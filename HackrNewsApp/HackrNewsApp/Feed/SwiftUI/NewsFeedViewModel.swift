//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import HackrNews

public final class NewsFeedViewModel {
    public private(set) var title: String = ""
    private let contentType: ContentType
    private let hackrNewsFeedloader: () -> AnyPublisher<[HackrNew], Error>
    private var cancellables = Set<AnyCancellable>()

    public init(contentType: ContentType, hackrNewsFeedloader: @escaping () -> AnyPublisher<[HackrNew], Error>) {
        self.contentType = contentType
        self.hackrNewsFeedloader = hackrNewsFeedloader
        selectTitle(from: contentType)
    }

    public func load() {
        hackrNewsFeedloader().sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &cancellables)
    }

    private func selectTitle(from contentType: ContentType) {
        switch contentType {
        case .topStories:
            title = HackrNewsFeedPresenter.topStoriesTitle
        case .newStories:
            title = HackrNewsFeedPresenter.newStoriesTitle
        case .bestStories:
            title = HackrNewsFeedPresenter.bestStoriesTitle
        }
    }
}
