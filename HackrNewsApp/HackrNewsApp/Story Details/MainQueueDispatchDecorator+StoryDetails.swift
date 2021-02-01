//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

extension MainQueueDispatchDecorator: CommentLoader where T == CommentLoader {
    func load(completion: @escaping (CommentLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
