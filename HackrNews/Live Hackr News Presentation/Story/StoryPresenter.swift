//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct StoryViewModel {
    public let newId: Int
}

public protocol StoryView {
    func display(_ viewModel: StoryViewModel)
}

public struct StoryLoadingViewModel {
    public let isLoading: Bool
}

public protocol StoryLoadingView {
    func display(_ viewModel: StoryLoadingViewModel)
}

public struct StoryErrorViewModel {
    public let message: String?
}

public protocol StoryErrorView {
    func display(_ viewModel: StoryErrorViewModel)
}

public final class StoryPresenter {
    private let view: StoryView
    private let loadingView: StoryLoadingView
    private let errorView: StoryErrorView

    public init(view: StoryView, loadingView: StoryLoadingView, errorView: StoryErrorView) {
        self.view = view
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public func didStartLoadingStory(from new: LiveHackrNew) {
        loadingView.display(StoryLoadingViewModel(isLoading: true))
        view.display(StoryViewModel(newId: new.id))
        errorView.display(StoryErrorViewModel(message: nil))
    }
}
