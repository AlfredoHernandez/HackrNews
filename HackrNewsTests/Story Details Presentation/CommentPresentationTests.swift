//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class CommentPresentationTests: XCTestCase {
    func test_map_createsViewModel() {
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let comment = StoryComment(
            id: 1,
            deleted: false,
            author: "an author",
            comments: [],
            parent: 0,
            text: "a text",
            createdAt: Date().adding(min: -1),
            type: "comment"
        )

        let result = CommentPresenter.map(comment, calendar: calendar, locale: locale)

        XCTAssertEqual(result, CommentViewModel(author: comment.author!, text: comment.text, createdAt: "1 minute ago"))
    }

    func test_map_createsViewModelForDeletedComment() {
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let deletedComment = StoryComment(
            id: 1,
            deleted: true,
            author: nil,
            comments: [],
            parent: 0,
            text: nil,
            createdAt: Date().adding(min: -5),
            type: "comment"
        )

        let result = CommentPresenter.map(deletedComment, calendar: calendar, locale: locale)

        XCTAssertEqual(result, CommentViewModel(author: localized("story_details_comment_deleted"), text: nil, createdAt: "5 minutes ago"))
    }

    // MARK: - Helpers

    private func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "StoryDetails"
        let bundle = Bundle(for: StoryDetailsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if key == value {
            XCTFail("Missing localized string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
}
