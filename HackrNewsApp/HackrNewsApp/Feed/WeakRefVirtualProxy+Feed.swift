//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

// MARK: - Resource

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}

// MARK: - Stories

extension WeakRefVirtualProxy: StoryView where T: StoryView {
    func display(_ viewModel: StoryViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: StoryLoadingView where T: StoryLoadingView {
    func display(_ viewModel: StoryLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: StoryErrorView where T: StoryErrorView {
    func display(_ viewModel: StoryErrorViewModel) {
        object?.display(viewModel)
    }
}
