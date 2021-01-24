//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public typealias RemoteLiveHackrNewsLoader = RemoteLoader<[LiveHackrNew]>

public extension RemoteLiveHackrNewsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: HackrNewsFeedMapper.map)
    }
}
