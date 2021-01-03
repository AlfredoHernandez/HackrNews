//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol HackrStoryLoaderTask {
    func cancel()
}

public protocol HackrStoryLoader {
    typealias Result = Swift.Result<Story, Swift.Error>
    func load(completion: @escaping (Result) -> Void) -> HackrStoryLoaderTask
}
