//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class RemoteHackrStoryLoader: HackrStoryLoader {
    private let url: URL
    private let client: HTTPClient

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }

    public typealias Result = HackrStoryLoader.Result

    public func load(completion: @escaping (Result) -> Void) -> HackrStoryLoaderTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result.mapError { _ in Error.connectivity }.flatMap(RemoteHackrStoryLoader.map))
        }
        return task
    }

    private final class HTTPTaskWrapper: HackrStoryLoaderTask {
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
            return .success(try StoryItemMapper.map(data: data, response: response))
        } catch {
            return .failure(error)
        }
    }
}
