//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public enum RetrieveCachedNewsesult {
    case empty
    case found(news: [LocalLiveHackrNew], timestamp: Date)
    case failure(Error)
}

public protocol LiveHackrNewsStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedNewsesult) -> Void

    func deleteCachedNews(completion: @escaping DeletionCompletion)
    func insertCacheNews(_ news: [LocalLiveHackrNew], with timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
