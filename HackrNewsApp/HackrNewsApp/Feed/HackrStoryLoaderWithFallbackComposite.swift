//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

class HackrStoryLoaderWithFallbackComposite {
    private let primary: HackrStoryLoader
    private let fallback: HackrStoryLoader

    init(primary: HackrStoryLoader, fallback: HackrStoryLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func load(id: Int, completion: @escaping (HackrStoryLoader.Result) -> Void) {
        _ = primary.load(id: id) { [weak self] result in
            switch result {
            case .failure:
                _ = self?.fallback.load(id: id, completion: completion)
            default:
                break
            }
        }
    }
}
