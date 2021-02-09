//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class LocalHackrNewsFeedLoader {
    private let store: HackrNewsFeedStore
    private let currentDate: () -> Date

    public init(store: HackrNewsFeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

// MARK: - Save Cache

public extension LocalHackrNewsFeedLoader {
    typealias SaveResult = Error?

    func save(_ news: [HackrNew], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedNews { [weak self] deletionError in
            guard let self = self else { return }
            guard deletionError == nil else { return completion(deletionError) }
            self.cache(news, with: completion)
        }
    }

    private func cache(_ news: [HackrNew], with completion: @escaping (SaveResult) -> Void) {
        store.insertCacheNews(news.toLocal(), with: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
}

// MARK: - Load Cache

extension LocalHackrNewsFeedLoader: HackrNewsFeedLoader {
    public typealias LoadResult = HackrNewsFeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some(cache)) where CachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
            case let .failure(error):
                completion(.failure(error))
            case .success(.some), .success(.none):
                completion(.success([]))
            }
        }
    }
}

// MARK: - Cache validation

public extension LocalHackrNewsFeedLoader {
    func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(.some(cache)) where !CachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedNews { _ in }
            case .failure:
                self.store.deleteCachedNews { _ in }
            case .success(.some), .success(.none):
                break
            }
        }
    }
}

extension Array where Element == HackrNew {
    func toLocal() -> [LocalHackrNew] {
        map { LocalHackrNew(id: $0.id) }
    }
}

extension Array where Element == LocalHackrNew {
    func toModels() -> [HackrNew] {
        map { HackrNew(id: $0.id) }
    }
}
