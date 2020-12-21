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
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                completion(RemoteHackrStoryLoader.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
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
