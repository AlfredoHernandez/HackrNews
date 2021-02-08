//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class RemoteLoader<Resource> {
    private let url: URL
    private let client: HTTPClient
    private let mapper: Mapper

    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    public typealias Result = Swift.Result<Resource, Swift.Error>

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
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

    public func load(completion: @escaping (Result) -> Void) -> HTTPClientTask {
        let task = HTTPTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            task.complete(with: result.mapError { _ in Error.connectivity }.flatMap(self.map))
        }
        return task
    }

    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            return .success(try mapper(data, response))
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
