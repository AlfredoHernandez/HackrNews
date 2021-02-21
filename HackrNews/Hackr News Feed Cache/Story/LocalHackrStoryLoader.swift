//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class LocalHackrStoryLoader {
    private let store: HackrNewsStoryStore
    private let currentDate: () -> Date

    public init(store: HackrNewsStoryStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public typealias ValidationResult = Result<Void, Swift.Error>

    public func validate(cacheforStory id: Int, completion: @escaping (ValidationResult) -> Void) {
        store.retrieve(storyID: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some(cache)) where !StoryCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.delete(storyID: id, completion: completion)
            case .failure:
                self.store.delete(storyID: id, completion: completion)
            case .success(.none), .success:
                completion(.success(()))
            }
        }
    }
}

// MARK: - Save Cache

extension LocalHackrStoryLoader: HackrStoryCache {
    public typealias SaveResult = HackrStoryCache.SaveResult

    public func save(_ story: Story, completion: @escaping (SaveResult) -> Void) {
        store.delete(storyID: story.id) { [weak self] deletionResult in
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
        store.insert(story: story.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
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

extension LocalHackrStoryLoader: HackrStoryLoader {
    public typealias LoadResult = HackrStoryLoader.Result

    public enum Error: Swift.Error {
        case storyNotFound
        case expiredCache
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

    public func load(id: Int, completion: @escaping (LoadResult) -> Void) -> HackrStoryLoaderTask {
        let task = LoadStoryTask(completion: completion)
        store.retrieve(storyID: id) { [weak self] retrievalResult in
            guard let self = self else { return }
            switch retrievalResult {
            case let .success(.some(cache)) where StoryCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                task.complete(with: .success(cache.story.toModel()))
            case let .failure(error):
                task.complete(with: .failure(error))
            case .success(.none):
                task.complete(with: .failure(Error.storyNotFound))
            case .success:
                task.complete(with: .failure(Error.expiredCache))
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
