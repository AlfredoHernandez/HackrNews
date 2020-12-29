//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class LocalLiveHackrNewsLoader {
    private let store: LiveHackrNewsStore
    private let currentDate: () -> Date

    public init(store: LiveHackrNewsStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }

    public func save(_ news: [LiveHackrNew], completion: @escaping (Error?) -> Void) {
        store.deleteCachedNews { [weak self] deletionError in
            guard let self = self else { return }
            guard deletionError == nil else { return completion(deletionError) }
            self.cache(news, with: completion)
        }
    }

    private func cache(_ news: [LiveHackrNew], with completion: @escaping (Error?) -> Void) {
        store.insertCacheNews(news, with: currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
        }
    }
}
