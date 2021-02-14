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
        store.delete(story) { [weak self] deletionResult in
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
        store.insert(story: story, with: timestamp()) { [weak self] insertionResult in
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

    func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { retrievalResult in
            _ = retrievalResult.mapError { error -> Error in
                completion(.failure(error))
                return error
            }
        }
    }
}
