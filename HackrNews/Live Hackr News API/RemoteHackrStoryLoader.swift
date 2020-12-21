//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class RemoteHackrStoryLoader {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public typealias Result = Swift.Result<Story, Swift.Error>

    public func load(from url: URL, completion _: @escaping (Result) -> Void) {
        client.get(from: url) { _ in
        }
    }
}
