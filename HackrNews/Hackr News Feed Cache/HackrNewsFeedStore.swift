//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct CachedFeed {
    public let feed: [LocalHackrNew]
    public let timestamp: Date

    public init(feed: [LocalHackrNew], timestamp: Date) {
        self.feed = feed
        self.timestamp = timestamp
    }
}

public protocol HackrNewsFeedStore {
    typealias DeletionCompletion = (Error?) -> Void

    typealias InsertionCompletion = (Error?) -> Void

    typealias RetrievalResult = Swift.Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    /// Completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedNews(completion: @escaping DeletionCompletion)

    /// Completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insertCacheNews(_ news: [LocalHackrNew], with timestamp: Date, completion: @escaping InsertionCompletion)

    /// Completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
