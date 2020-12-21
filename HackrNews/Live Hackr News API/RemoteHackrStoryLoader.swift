//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class RemoteHackrStoryLoader: HackrStoryLoader {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }

    public typealias Result = HackrStoryLoader.Result

    public func load(from url: URL, completion: @escaping (Result) -> Void) -> HackrStoryLoaderTask {
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
            let item = try StoryItemMapper.map(data: data, response: response)
            return .success(item.toModel())
        } catch {
            return .failure(error)
        }
    }
}

extension StoryItemMapper.Item {
    func toModel() -> Story {
        Story(
            id: id,
            title: title,
            author: by,
            score: score,
            createdAt: time,
            totalComments: descendants,
            comments: kids,
            type: type,
            url: url
        )
    }
}
