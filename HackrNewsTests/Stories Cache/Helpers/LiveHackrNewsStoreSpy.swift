//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

class LiveHackrNewsStoreSpy: LiveHackrNewsStore {
    private(set) var deletionRequests = [DeletionCompletion]()
    private(set) var insertionRequests = [InsertionCompletion]()
    private(set) var retrievalRequests = [RetrievalCompletion]()
    private(set) var receivedMessages = [ReceivedMessage]()

    enum ReceivedMessage: Equatable {
        case deletion
        case insertion([LocalLiveHackrNew], Date)
        case retrieve
    }

    func deleteCachedNews(completion: @escaping DeletionCompletion) {
        deletionRequests.append(completion)
        receivedMessages.append(.deletion)
    }

    func insertCacheNews(_ news: [LocalLiveHackrNew], with timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionRequests.append(completion)
        receivedMessages.append(.insertion(news, timestamp))
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionRequests[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionRequests[index](.none)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionRequests[index](error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionRequests[index](.none)
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalRequests.append(completion)
        receivedMessages.append(.retrieve)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalRequests[index](error)
    }

    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalRequests[index](nil)
    }
}
