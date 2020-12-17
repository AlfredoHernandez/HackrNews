//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: LiveHackrNewsLoadingView where T: LiveHackrNewsLoadingView {
    func display(_ viewModel: LiveHackrNewsLoadingViewModel) {
        object?.display(viewModel)
    }
}
