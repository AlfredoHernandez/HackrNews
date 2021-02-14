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
        store.delete(story) { [unowned self] deletionResult in
            switch deletionResult {
            case .success:
                self.cache(story, with: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ story: Story, with completion: @escaping (SaveResult) -> Void) {
        store.insert(story: story, with: timestamp()) { insertionResult in
            switch insertionResult {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
