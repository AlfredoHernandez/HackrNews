//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct LiveHackrNew: Equatable {
    public let id: Int
    public let url: URL

    public init(id: Int, url: URL) {
        self.id = id
        self.url = url
    }
}

public protocol LiveHackrNewsLoader {
    typealias Result = Swift.Result<[LiveHackrNew], Swift.Error>
    func load(completion: @escaping (Result) -> Void)
}

public protocol HackrStoryLoaderTask {
    func cancel()
}

public protocol HackrStoryLoader {
    typealias Result = Swift.Result<Story, Swift.Error>
    func load(from url: URL, completion: @escaping (Result) -> Void) -> HackrStoryLoaderTask
}
