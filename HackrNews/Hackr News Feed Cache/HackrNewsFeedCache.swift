//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol HackrNewsFeedCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ news: [HackrNew], completion: @escaping (SaveResult) -> Void)
}
