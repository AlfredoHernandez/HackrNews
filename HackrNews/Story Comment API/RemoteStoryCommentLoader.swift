//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public typealias RemoteStoryCommentLoader = RemoteLoader<StoryComment>

public extension RemoteStoryCommentLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: StoryCommentMapper.map)
    }
}
