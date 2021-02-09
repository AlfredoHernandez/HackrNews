//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

class HackrNewsFeedStoreSpy: HackrNewsFeedStore {
    private(set) var deletionRequests = [DeletionCompletion]()
    private(set) var insertionRequests = [InsertionCompletion]()
    private(set) var retrievalRequests = [RetrievalCompletion]()
    private(set) var receivedMessages = [ReceivedMessage]()

    enum ReceivedMessage: Equatable {
        case deletion
        case insertion([LocalHackrNew], Date)
        case retrieve
    }

    func deleteCachedNews(completion: @escaping DeletionCompletion) {
        deletionRequests.append(completion)
        receivedMessages.append(.deletion)
    }

    func insertCacheNews(_ news: [LocalHackrNew], with timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionRequests.append(completion)
        receivedMessages.append(.insertion(news, timestamp))
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionRequests[index](.failure(error))
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionRequests[index](.success(()))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionRequests[index](.failure(error))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionRequests[index](.success(()))
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalRequests.append(completion)
        receivedMessages.append(.retrieve)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalRequests[index](.failure(error))
    }

    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalRequests[index](.success(.none))
    }

    func completeRetrieval(with news: [LocalHackrNew], timestamp: Date, at index: Int = 0) {
        retrievalRequests[index](.success(CachedFeed(feed: news, timestamp: timestamp)))
    }
}
