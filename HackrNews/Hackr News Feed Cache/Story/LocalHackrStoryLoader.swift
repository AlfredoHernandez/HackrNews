//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class LocalHackrStoryLoader {
    private let store: HackrNewsStoryStore
    private let timestamp: () -> Date

    public init(store: HackrNewsStoryStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
}

// MARK: - Save Cache

extension LocalHackrStoryLoader: HackrStoryCache {
    public typealias SaveResult = HackrStoryCache.SaveResult

    public func save(_ story: Story, completion: @escaping (SaveResult) -> Void) {
        store.delete(story.toLocal()) { [weak self] deletionResult in
            guard let self = self else { return }
            switch deletionResult {
            case .success:
                self.cache(story, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ story: Story, with completion: @escaping (SaveResult) -> Void) {
        store.insert(story: story.toLocal(), with: timestamp()) { [weak self] insertionResult in
            guard self != nil else { return }
            switch insertionResult {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Load Cache

public extension LocalHackrStoryLoader {
    typealias LoadResult = HackrStoryLoader.Result

    enum Error: Swift.Error {
        case storyNotFound
    }

    class LoadStoryTask: HackrStoryLoaderTask {
        var completion: ((LoadResult) -> Void)?

        init(completion: @escaping (LoadResult) -> Void) {
            self.completion = completion
        }

        public func cancel() {
            preventFurtherCompletions()
        }

        func complete(with result: LoadResult) {
            completion?(result)
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    func load(id: Int, completion: @escaping (LoadResult) -> Void) -> HackrStoryLoaderTask {
        let task = LoadStoryTask(completion: completion)
        store.retrieve(storyID: id) { [weak self] retrievalResult in
            guard self != nil else { return }
            switch retrievalResult {
            case let .success(.some(story)):
                task.complete(with: .success(story.toModel()))
            case let .failure(error):
                task.complete(with: .failure(error))
            case .success:
                task.complete(with: .failure(Error.storyNotFound))
            }
        }
        return task
    }
}

public extension Story {
    func toLocal() -> LocalStory {
        LocalStory(
            id: id,
            title: title,
            text: text,
            author: author,
            score: score,
            createdAt: createdAt,
            totalComments: totalComments,
            comments: comments,
            type: type,
            url: url
        )
    }
}

public extension LocalStory {
    func toModel() -> Story {
        Story(
            id: id,
            title: title,
            text: text,
            author: author,
            score: score,
            createdAt: createdAt,
            totalComments: totalComments,
            comments: comments,
            type: type,
            url: url
        )
    }
}
