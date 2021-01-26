//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS

final class StoryPresentationAdapter: LiveHackrNewCellControllerDelegate {
    private let model: HackrNew
    private let loader: HackrStoryLoader
    private var task: HackrStoryLoaderTask?

    var presenter: StoryPresenter?

    init(model: HackrNew, loader: HackrStoryLoader) {
        self.model = model
        self.loader = loader
    }

    func didRequestStory() {
        presenter?.didStartLoadingStory(from: model)
        task = loader.load { [weak self] result in
            switch result {
            case let .success(story):
                self?.presenter?.didFinishLoadingStory(story: story)
            case let .failure(error):
                self?.presenter?.didFinishLoading(with: error)
            }
        }
    }

    func didCancelRequest() {
        task?.cancel()
    }
}
