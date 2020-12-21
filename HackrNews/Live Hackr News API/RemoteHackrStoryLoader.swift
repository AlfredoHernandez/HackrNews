//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class RemoteHackrStoryLoader {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }

    public typealias Result = Swift.Result<Story, Swift.Error>

    public func load(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                task.complete(with: RemoteHackrStoryLoader.map(data, response))
            case .failure:
                task.complete(with: .failure(Error.connectivity))
            }
        }
        return task
    }

    private final class HTTPTaskWrapper: HTTPClientTask {
        private var completion: ((Result) -> Void)?
        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: Result) {
            completion?(result)
        }

        func cancel() {
            wrapped?.cancel()
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    private static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do {
            let story = try StoryItemMapper.map(data: data, response: response)
            return .success(story)
        } catch {
            return .failure(error)
        }
    }
}
