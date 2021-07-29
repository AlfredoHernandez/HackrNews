//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

extension MainQueueDispatchDecorator: HackrStoryLoader where T == HackrStoryLoader {
    func load(id: Int, completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
        decoratee.load(id: id) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
