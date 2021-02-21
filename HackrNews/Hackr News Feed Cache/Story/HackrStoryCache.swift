//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol HackrStoryCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ story: Story, completion: @escaping (SaveResult) -> Void)
}
