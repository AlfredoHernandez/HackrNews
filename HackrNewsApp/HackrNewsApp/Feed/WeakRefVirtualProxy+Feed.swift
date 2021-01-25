//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

// MARK: - Live Hackr News

extension WeakRefVirtualProxy: LiveHackrNewsLoadingView where T: LiveHackrNewsLoadingView {
    func display(_ viewModel: LiveHackrNewsLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: LiveHackrNewsErrorView where T: LiveHackrNewsErrorView {
    func display(_ viewModel: LiveHackrNewsErrorViewModel) {
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
