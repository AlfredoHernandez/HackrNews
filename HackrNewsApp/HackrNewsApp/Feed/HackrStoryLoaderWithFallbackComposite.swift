//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

class HackrStoryLoaderWithFallbackComposite {
    private let primary: HackrStoryLoader

    init(primary: HackrStoryLoader, fallback _: HackrStoryLoader) {
        self.primary = primary
    }

    func load(id: Int, completion _: @escaping (HackrStoryLoader.Result) -> Void) {
        _ = primary.load(id: id) { _ in }
    }
}
