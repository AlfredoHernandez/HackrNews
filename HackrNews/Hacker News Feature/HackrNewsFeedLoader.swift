//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol HackrNewsFeedLoader {
    typealias Result = Swift.Result<[HackrNew], Swift.Error>
    func load(completion: @escaping (Result) -> Void)
}
