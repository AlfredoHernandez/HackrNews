//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class LocalLiveHackrNewsLoader {
    public typealias SaveResult = Error?
    public typealias LoadResult = LiveHackrNewsLoader.Result
    private let store: LiveHackrNewsStore
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    private var maxCacheAgeInDays: Int { 1 }

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
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .found(news: news, timestamp: timestamp) where self.validate(timestamp):
                completion(.success(news.toModels()))
            case let .failure(error):
                self.store.deleteCachedNews { _ in }
                completion(.failure(error))
            case .found:
                self.store.deleteCachedNews { _ in }
                fallthrough
            case .empty:
                completion(.success([]))
            }
        }
    }

    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return currentDate() < maxCacheAge
    }
}

extension Array where Element == LiveHackrNew {
    func toLocal() -> [LocalLiveHackrNew] {
        map { LocalLiveHackrNew(id: $0.id) }
    }
}

extension Array where Element == LocalLiveHackrNew {
    func toModels() -> [LiveHackrNew] {
        map { LiveHackrNew(id: $0.id) }
    }
}
