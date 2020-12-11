//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class NewStoriesPresentationTests: XCTestCase {
    func test_title_isLocalized() {
        XCTAssertEqual(NewStoriesPresenter.title, localized("new_stories_title"))
    }

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages upon creation")
    }

    func test_didStartLoadingStories_displaysLoaderWithNoErrorMessage() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingStories()

        XCTAssertEqual(view.messages, [.display(isLoading: true), .display(errorMessage: .none)])
    }

    func test_didFinishLoadingStories_displayStoriesAndStopsLoading() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingStories(stories: [1, 2, 3])

        XCTAssertEqual(view.messages, [.display(isLoading: false), .display(stories: [1, 2, 3])])
    }

    func test_didFinishLoadingStoriesWithError_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingStories(with: anyNSError())

        XCTAssertEqual(view.messages, [.display(isLoading: false), .display(errorMessage: localized("new_stories_error_message"))])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (NewStoriesPresenter, NewStoriesViewSpy) {
        let view = NewStoriesViewSpy()
        let sut = NewStoriesPresenter(view: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "NewStories"
        let bundle = Bundle(for: NewStoriesPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }

    private class NewStoriesViewSpy: NewStoriesView, NewStoriesLoadingView, NewStoriesErrorView {
        var messages = [Message]()

        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(errorMessage: String?)
            case display(stories: [LiveHackerNew])
        }

        func display(_ viewModel: NewStoriesErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }

        func display(_ viewModel: NewStoriesLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: NewStoriesViewModel) {
            messages.append(.display(stories: viewModel.stories))
        }
    }
}
