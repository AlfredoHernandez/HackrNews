//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(_ decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: LiveHackrNewsLoader where T == LiveHackrNewsLoader {
    func load(completion: @escaping (LiveHackrNewsLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: HackrStoryLoader where T == HackrStoryLoader {
    func load(completion: @escaping (HackrStoryLoader.Result) -> Void) -> HackrStoryLoaderTask {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
