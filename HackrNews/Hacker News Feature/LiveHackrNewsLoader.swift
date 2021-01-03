//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol LiveHackrNewsLoader {
    typealias Result = Swift.Result<[LiveHackrNew], Swift.Error>
    func load(completion: @escaping (Result) -> Void)
}
