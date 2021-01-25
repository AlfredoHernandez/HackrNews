//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public typealias RemoteHackrStoryLoader = RemoteLoader<Story>

public extension RemoteHackrStoryLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: StoryItemMapper.map)
    }
}
