//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
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
        let new = HackrNew(id: anyID())

        sut.didStartLoadingStory(from: new)

        XCTAssertEqual(view.messages, [.display(isLoading: true), .display(errorMessage: .none)])
    }

    func test_didFinishLoadingStory_displaysStoryAndStopsLoading() {
        let locale = Locale(identifier: "en_US_POSIX")
        let calendar = Calendar(identifier: .gregorian)
        let (sut, view) = makeSUT(locale: locale, calendar: calendar)
        let date = Date(timeIntervalSince1970: 1175714200)
        let url = URL(string: "https://any-url.com/a-link.html")!
        let story = Story(
            id: 1,
            title: "a title",
            text: "a text",
            author: "an author",
            score: 2,
            createdAt: date,
            totalComments: 10,
            comments: [1],
            type: "story",
            url: url
        )

        sut.didFinishLoadingStory(story: story)

        XCTAssertEqual(
            view.messages,
            [
                .display(isLoading: false),
                .display(
                    id: story.id,
                    title: story.title,
                    author: story.author,
                    comments: localized("story_comments_message", [story.totalComments ?? 0]),
                    score: localized("story_points_message", [story.score ?? 0]),
                    date: "Apr 04, 2007",
                    url: url,
                    displayURL: "any-url.com"
                ),
                .display(errorMessage: .none),
            ]
        )
    }

    func test_didFinishLoadingWithError_displaysErrorAndStopsLoading() {
        let (sut, view) = makeSUT()

        sut.didFinishLoading(with: anyNSError())

        XCTAssertEqual(view.messages, [.display(isLoading: false), .display(errorMessage: localized("story_error_message"))])
    }

    // MARK: - Helpers

    private func makeSUT(
        locale: Locale = .current,
        calendar: Calendar = Calendar(identifier: .gregorian),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (StoryPresenter, StoryViewSpy) {
        let view = StoryViewSpy()
        let sut = StoryPresenter(view: view, loadingView: view, errorView: view, locale: locale, calendar: calendar)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(view, file: file, line: line)
        return (sut, view)
    }

    private func localized(_ key: String, _ args: [CVarArg] = [], file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Story"
        let bundle = Bundle(for: StoryPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        return String(format: value, arguments: args)
    }

    private class StoryViewSpy: StoryView, StoryLoadingView, StoryErrorView {
        enum Message: Equatable {
            case display(isLoading: Bool)
            case display(
                id: Int,
                title: String?,
                author: String?,
                comments: String?,
                score: String?,
                date: String?,
                url: URL?,
                displayURL: String?
            )
            case display(errorMessage: String?)
        }

        private(set) var messages = [Message]()

        func display(_ viewModel: StoryViewModel) {
            messages
                .append(.display(
                    id: viewModel.newId,
                    title: viewModel.title,
                    author: viewModel.author,
                    comments: viewModel.comments,
                    score: viewModel.score,
                    date: viewModel.date,
                    url: viewModel.url,
                    displayURL: viewModel.displayURL
                ))
        }

        func display(_ viewModel: StoryLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }

        func display(_ viewModel: StoryErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.error))
        }
    }
}
