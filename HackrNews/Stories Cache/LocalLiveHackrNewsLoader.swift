//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class LocalLiveHackrNewsLoader {
    public typealias SaveResult = Error?
    public typealias LoadResult = LiveHackrNewsLoader.Result
    private let store: LiveHackrNewsStore
    private let currentDate: () -> Date

    public init(store: LiveHackrNewsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public func save(_ news: [LiveHackrNew], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedNews { [weak self] deletionError in
            guard let self = self else { return }
            guard deletionError == nil else { return completion(deletionError) }
            self.cache(news, with: completion)
        }
    }

    private func cache(_ news: [LiveHackrNew], with completion: @escaping (SaveResult) -> Void) {
        store.insertCacheNews(news.toLocal(), with: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success([]))
            }
        }
    }
}

extension Array where Element == LiveHackrNew {
    func toLocal() -> [LocalLiveHackrNew] {
        map { LocalLiveHackrNew(id: $0.id) }
    }
}
