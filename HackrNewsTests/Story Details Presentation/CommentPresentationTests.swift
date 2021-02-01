//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

struct CommentViewModel {
    let isLoading: Bool

    static let loading = CommentViewModel(isLoading: true)
}

protocol CommentView {
    func display(_ viewModel: CommentViewModel)
}

class CommentPresenter {
    private let view: CommentView
    init(view: CommentView) {
        self.view = view
    }

    func didStartLoadingComment() {
        view.display(.loading)
    }
}

final class CommentPresentationTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let view = CommentViewSpy()
        _ = CommentPresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages upon creation")
    }

    func test_didStartLoadingComment_displaysLoader() {
        let view = CommentViewSpy()
        let sut = CommentPresenter(view: view)

        sut.didStartLoadingComment()

        XCTAssertEqual(view.messages, [.display(isLoading: true)])
    }

    // MARK: - Helpers

    private class CommentViewSpy: CommentView {
        enum Message: Equatable {
            case display(isLoading: Bool)
        }

        var messages = [Message]()

        func display(_ viewModel: CommentViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
}
