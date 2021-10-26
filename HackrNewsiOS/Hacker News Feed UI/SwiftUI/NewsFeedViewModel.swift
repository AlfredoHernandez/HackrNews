//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import Foundation
import HackrNews

public final class NewsFeedViewModel: ObservableObject {
    private let contentType: ContentType
    private let hackrNewsFeedloader: () -> AnyPublisher<[HackrNew], Error>
    private var cancellables = Set<AnyCancellable>()
    private var canStartLoading = true
    private var viewDidLoad = false
    
    public private(set) var title: String = ""
    @Published public private(set) var news: [HackrNew] = []

    public init(news: [HackrNew] = [], contentType: ContentType, hackrNewsFeedloader: @escaping () -> AnyPublisher<[HackrNew], Error>) {
        self.news = news
        self.contentType = contentType
        self.hackrNewsFeedloader = hackrNewsFeedloader
        selectTitle(from: contentType)
    }

    public func load() {
        if !viewDidLoad {
            refresh()
            viewDidLoad = true
        }
    }

    public func refresh() {
        if canStartLoading {
            canStartLoading = false
            hackrNewsFeedloader()
                .receive(on: DispatchQueue.main, options: .none)
                .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] news in
                self?.canStartLoading = true
                self?.news = news
            }).store(in: &cancellables)
        }
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
