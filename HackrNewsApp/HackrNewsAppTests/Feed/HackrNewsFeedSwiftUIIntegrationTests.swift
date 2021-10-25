//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
@testable import HackrNewsApp
import HackrNewsiOS
import XCTest

class HackrNewsFeedViewModel {
    public private(set) var title: String = ""
    private let contentType: ContentType

    init(contentType: ContentType) {
        self.contentType = contentType
        selectTitle(from: contentType)
    }

    private func selectTitle(from contentType: ContentType) {
        switch contentType {
        case .topStories:
            title = HackrNewsFeedPresenter.topStoriesTitle
        case .newStories:
            title = HackrNewsFeedPresenter.newStoriesTitle
        case .bestStories:
            title = HackrNewsFeedPresenter.bestStoriesTitle
        }
    }
}

final class HackrNewsFeedSwiftUIIntegrationTests: XCTestCase {
    func test_view_hasTitle() {
        let sutA = makeSUT(contentType: .topStories)
        XCTAssertEqual(sutA.title, HackrNewsFeedPresenter.topStoriesTitle)

        let sutB = makeSUT(contentType: .bestStories)
        XCTAssertEqual(sutB.title, HackrNewsFeedPresenter.bestStoriesTitle)

        let sutC = makeSUT(contentType: .newStories)
        XCTAssertEqual(sutC.title, HackrNewsFeedPresenter.newStoriesTitle)
    }

    // MARK: - Helpers

    private func makeSUT(contentType: ContentType) -> HackrNewsFeedViewModel {
        let sut = HackrNewsFeedViewModel(contentType: contentType)
        return sut
    }
}
