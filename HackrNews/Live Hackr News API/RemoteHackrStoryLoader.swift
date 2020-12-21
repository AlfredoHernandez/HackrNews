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
        case connectivity
    }

    public typealias Result = Swift.Result<Story, Swift.Error>

    public func load(from url: URL, completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                break
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}
