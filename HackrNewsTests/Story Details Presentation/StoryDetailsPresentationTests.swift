//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class StoryDetailsPresentationTests: XCTestCase {
    func test_storyDetailsTitle_isLocalized() {
        XCTAssertEqual(StoryDetailsPresenter.title, localized("story_details_title"))
    }

    func test_map_createViewModel() {
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let now = Date()

        let (story0, viewModel0) = makeStoryDetail(
            title: "a title",
            text: "a text",
            author: "an author",
            score: 10,
            createdAt: (now.adding(days: -1), "1 day ago"),
            totalComments: 1,
            comments: [1],
            url: anyURL()
        )

        let (story1, viewModel1) = makeStoryDetail(
            title: nil,
            text: nil,
            author: "an author",
            score: nil,
            createdAt: (now.adding(min: -30), "30 minutes ago"),
            totalComments: nil,
            comments: nil,
            url: nil
        )

        let resultViewModel0 = StoryDetailsPresenter.map(story0, calendar: calendar, locale: locale)
        let resultViewModel1 = StoryDetailsPresenter.map(story1, calendar: calendar, locale: locale)

        expect(viewModel: resultViewModel0, equalsTo: viewModel0)
        expect(viewModel: resultViewModel1, equalsTo: viewModel1)
    }

    // MARK: - Helpers

    private func makeStoryDetail(
        title: String?,
        text: String?,
        author: String,
        score: Int?,
        createdAt: (date: Date, string: String),
        totalComments: Int?,
        comments: [Int]?,
        url: URL?
    ) -> (StoryDetail, StoryDetailViewModel) {
        let storyDetail = StoryDetail(
            title: title,
            text: text,
            author: author,
            score: score,
            createdAt: createdAt.date,
            totalComments: totalComments,
            comments: comments,
            url: url
        )
        let viewModel = StoryDetailViewModel(
            title: title,
            text: text,
            author: author,
            score: (score != nil) ? "\(score!) points" : nil,
            comments: (totalComments != nil) ? "\(totalComments!) comments" : nil,
            createdAt: createdAt.string,
            displayURL: url?.host
        )

        return (storyDetail, viewModel)
    }

    private func expect(viewModel: StoryDetailViewModel, equalsTo expectedViewModel: StoryDetailViewModel) {
        XCTAssertEqual(viewModel.title, expectedViewModel.title)
        XCTAssertEqual(viewModel.text, expectedViewModel.text)
        XCTAssertEqual(viewModel.author, expectedViewModel.author)
        XCTAssertEqual(viewModel.score, expectedViewModel.score)
        XCTAssertEqual(viewModel.comments, expectedViewModel.comments)
        XCTAssertEqual(viewModel.createdAt, expectedViewModel.createdAt)
        XCTAssertEqual(viewModel.displayURL, expectedViewModel.displayURL)
    }

    private func localized(_ key: String, params: [CVarArg] = [], file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "StoryDetails"
        let bundle = Bundle(for: StoryDetailsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        if params.count > 0 {
            return String(format: value, params)
        }
        return value
    }
}
