//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

// MARK: - Live Hackr News

extension WeakRefVirtualProxy: HackrNewsFeedLoadingView where T: HackrNewsFeedLoadingView {
    func display(_ viewModel: HackrNewsFeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: HackrNewsFeedErrorView where T: HackrNewsFeedErrorView {
    func display(_ viewModel: HackrNewsFeedErrorViewModel) {
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
