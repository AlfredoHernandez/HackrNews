//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol LiveHackrNewsStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedNews(completion: @escaping DeletionCompletion)
    func insertCacheNews(_ news: [LocalLiveHackrNew], with timestamp: Date, completion: @escaping InsertionCompletion)
    func retrieve()
}
