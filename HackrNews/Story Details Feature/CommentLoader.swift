//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol CommentLoaderTask {
    func cancel()
}

public protocol CommentLoader {
    typealias Result = Swift.Result<StoryComment, Swift.Error>
    func load(completion: @escaping (Result) -> Void) -> CommentLoaderTask
}
