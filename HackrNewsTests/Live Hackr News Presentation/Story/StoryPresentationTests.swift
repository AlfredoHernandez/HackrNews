//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class StoryPresentationTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages upon creation")
    }

    func test_didStartLoadingStory_displaysLoaderAndHidesError() {
        let (sut, view) = makeSUT()
        let new = LiveHackrNew(id: anyID(), url: anyURL())

        sut.didStartLoadingStory(from: new)

        XCTAssertEqual(view.messages, [.display(isLoading: true), .display(id: new.id), .display(errorMessage: .none)])
    }

    // MARK: - Helpers

    private func makeSUT() -> (StoryPresenter, StoryViewSpy) {
        let view = StoryViewSpy()
        let sut = StoryPresenter(view: view, loadingView: view, errorView: view)
        return (sut, view)
    }

    private class StoryViewSpy: StoryView, StoryLoadingView, StoryErrorView {
        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(id: Int)
            case display(errorMessage: String?)
        }

        private(set) var messages = [Message]()

        func display(_ viewModel: StoryViewModel) {
            messages.append(.display(id: viewModel.newId))
        }

        func display(_ viewModel: StoryLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: StoryErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
