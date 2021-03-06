//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS

final class StoryPresentationAdapter: HackrNewFeedCellControllerDelegate {
    private let model: HackrNew
    private let loader: HackrStoryLoader
    private var task: HackrStoryLoaderTask?
    private var isLoading = false
    var storyResult: (() -> Story)?

    var presenter: StoryPresenter?

    init(model: HackrNew, loader: HackrStoryLoader) {
        self.model = model
        self.loader = loader
    }

    func didRequestStory() {
        presenter?.didStartLoadingStory(from: model)
        guard !isLoading else { return }
        isLoading = true
        task = loader.load(id: model.id) { [weak self] result in
            switch result {
            case let .success(story):
                self?.storyResult = { story }
                self?.presenter?.didFinishLoadingStory(story: story)
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
            self?.isLoading = false
        }
    }

    func didCancelRequest() {
        task?.cancel()
        isLoading = false
    }
}
