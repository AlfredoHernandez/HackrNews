//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public typealias LiveHackerNew = Int

public protocol LiveHackrNewsLoader {
    typealias Result = Swift.Result<[LiveHackerNew], Swift.Error>
    func load(completion: @escaping (Result) -> Void)
}
