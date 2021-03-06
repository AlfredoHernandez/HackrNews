//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class CodableHackrNewsFeedStore: HackrNewsFeedStore {
    private struct Cache: Codable {
        let news: [CodableHackrNew]
        let timestamp: Date

        var localFeed: [LocalHackrNew] {
            news.map(\.local)
        }
    }

    private struct CodableHackrNew: Codable {
        private let id: Int

        init(_ localHackrNew: LocalHackrNew) {
            id = localHackrNew.id
        }

        var local: LocalHackrNew {
            LocalHackrNew(id: id)
        }
    }

    private let queue = DispatchQueue(
        label: "com.alfredohdz.HackrNews.store-\(CodableHackrNewsFeedStore.self)Queue",
        qos: .userInitiated,
        attributes: .concurrent
    )

    private let storeUrl: URL

    public init(storeURL: URL) {
        storeUrl = storeURL
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeUrl = self.storeUrl
        queue.async {
            guard let data = try? Data(contentsOf: storeUrl) else {
                return completion(.success(.none))
            }
            do {
                let decoder = JSONDecoder()
                let decoded = try decoder.decode(Cache.self, from: data)
                completion(.success(CachedFeed(feed: decoded.localFeed, timestamp: decoded.timestamp)))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func insertCacheNews(_ news: [LocalHackrNew], with timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeUrl = self.storeUrl
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(news: news.map(CodableHackrNew.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeUrl)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func deleteCachedNews(completion: @escaping DeletionCompletion) {
        let storeUrl = self.storeUrl
        queue.async(flags: .barrier) {
            do {
                guard FileManager.default.fileExists(atPath: storeUrl.path) else {
                    return completion(.success(()))
                }
                try FileManager.default.removeItem(at: storeUrl)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
