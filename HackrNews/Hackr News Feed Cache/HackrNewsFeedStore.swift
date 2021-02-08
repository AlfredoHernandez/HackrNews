//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(news: [LocalHackrNew], timestamp: Date)
    case failure(Error)
}

public protocol HackrNewsFeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void

    func deleteCachedNews(completion: @escaping DeletionCompletion)
    func insertCacheNews(_ news: [LocalHackrNew], with timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
