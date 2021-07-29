//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import HackrNews
import HackrNewsiOS

final class StoryPresentationAdapter: HackrNewFeedCellControllerDelegate {
    private let model: HackrNew
    private let loader: () -> AnyPublisher<Story, Error>
    private var task: Cancellable?
    private var isLoading = false
    var storyResult: (() -> Story)?

    var presenter: StoryPresenter?

    init(model: HackrNew, loader: @escaping () -> AnyPublisher<Story, Error>) {
        self.model = model
        self.loader = loader
    }

    func didRequestStory() {
        presenter?.didStartLoadingStory(from: model)
        guard !isLoading else { return }
        isLoading = true

        task = loader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
                self?.isLoading = false
            }, receiveValue: { [weak self] story in
                self?.storyResult = { story }
                self?.presenter?.didFinishLoadingStory(story: story)
            })
    }

    func didCancelRequest() {
        task?.cancel()
        isLoading = false
    }
}
