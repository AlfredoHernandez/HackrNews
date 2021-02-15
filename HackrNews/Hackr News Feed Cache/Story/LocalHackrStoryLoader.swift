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

public extension LocalHackrStoryLoader {
    typealias LoadResult = HackrStoryLoader.Result

    enum Error: Swift.Error {
        case storyNotFound
    }

    func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { retrievalResult in
            switch retrievalResult {
            case let .success(story):
                if story == nil {
                    completion(.failure(Error.storyNotFound))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
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
