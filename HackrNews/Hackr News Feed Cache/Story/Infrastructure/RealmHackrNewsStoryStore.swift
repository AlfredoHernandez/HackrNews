//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class RealmHackrNewsStoryStore {
    public typealias RetrievalResult = Swift.Result<LocalStory?, Error>
    public typealias RetrievalCompletion = (RetrievalResult) -> Void

    public init() {}

    public func retrieve(storyID _: Int, completion: @escaping RetrievalCompletion) {
        completion(.success(nil))
    }
}
