//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Combine
import HackrNews
@testable import HackrNewsApp
import HackrNewsiOS
import XCTest

class HackrNewsFeedViewModel {
    public private(set) var title: String = ""
    private let contentType: ContentType
    private let hackrNewsFeedloader: () -> AnyPublisher<[HackrNew], Error>
    private var cancellables = Set<AnyCancellable>()

    init(contentType: ContentType, hackrNewsFeedloader: @escaping () -> AnyPublisher<[HackrNew], Error>) {
        self.contentType = contentType
        self.hackrNewsFeedloader = hackrNewsFeedloader
        selectTitle(from: contentType)
    }

    func load() {
        hackrNewsFeedloader().sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &cancellables)
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
        let (sutA, _) = makeSUT(contentType: .topStories)
        XCTAssertEqual(sutA.title, HackrNewsFeedPresenter.topStoriesTitle)

        let (sutB, _) = makeSUT(contentType: .bestStories)
        XCTAssertEqual(sutB.title, HackrNewsFeedPresenter.bestStoriesTitle)

        let (sutC, _) = makeSUT(contentType: .newStories)
        XCTAssertEqual(sutC.title, HackrNewsFeedPresenter.newStoriesTitle)
    }

    func test_loadHackrNewsFeedActions_requestHackrNewsFeedLoader() {
        let (sut, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)

        sut.load()
        XCTAssertEqual(loader.loadCallCount, 1)

        loader.completeHackrNewsFeedLoading(at: 0)
        sut.simulateUserInitiatedHackrNewsFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        loader.completeHackrNewsFeedLoading(at: 1)
        sut.simulateUserInitiatedHackrNewsFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }

    // MARK: - Helpers

    private func makeSUT(
        contentType: ContentType = .topStories,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (HackrNewsFeedViewModel, HackrNewsFeedLoaderSpy) {
        let loader = HackrNewsFeedLoaderSpy()
        let sut = HackrNewsFeedViewModel(contentType: contentType, hackrNewsFeedloader: {
            loader.publisher()
        })
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        return (sut, loader)
    }
}

extension HackrNewsFeedViewModel {
    func simulateUserInitiatedHackrNewsFeedReload() {
        load()
    }
}
