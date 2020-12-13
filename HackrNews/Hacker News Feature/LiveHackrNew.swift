//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public typealias LiveHackrNew = Int

public protocol LiveHackrNewsLoader {
    typealias Result = Swift.Result<[LiveHackrNew], Swift.Error>
    func load(completion: @escaping (Result) -> Void)
}
