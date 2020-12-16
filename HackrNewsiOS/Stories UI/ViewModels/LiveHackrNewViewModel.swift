//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

final class LiveHackrNewViewModel {
    private var task: HackrStoryLoaderTask?
    private let loader: HackrStoryLoader
    private let model: LiveHackrNew
    typealias Observable<T> = (T) -> Void

    var onLoadingStateChanged: Observable<Bool>?
    var onShouldRetryLoadStory: Observable<Bool>?
    var onStoryLoad: Observable<Story>?

    init(model: LiveHackrNew, loader: HackrStoryLoader) {
        self.model = model
        self.loader = loader
    }

    func preload() {
        task = loader.load(from: model.url) { _ in }
    }

    func load() {
        onLoadingStateChanged?(true)
        onShouldRetryLoadStory?(false)
        task = loader.load(from: model.url) { [weak self] result in
            if let data = try? result.get() {
                self?.onStoryLoad?(data)
            } else {
                self?.onShouldRetryLoadStory?(true)
            }
            self?.onLoadingStateChanged?(false)
        }
    }

    func cancelLoad() {
        task?.cancel()
    }

    var storyId: Int { model.id }
}
