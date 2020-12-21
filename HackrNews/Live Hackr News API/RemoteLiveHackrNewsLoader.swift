//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public final class RemoteLiveHackrNewsLoader: LiveHackrNewsLoader {
    private let url: URL
    private let client: HTTPClient

    public typealias Result = LiveHackrNewsLoader.Result

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion _: @escaping (Result) -> Void) {
        client.get(from: url) { _ in }
    }
}
