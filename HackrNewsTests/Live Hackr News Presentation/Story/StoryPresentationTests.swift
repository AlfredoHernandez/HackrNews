//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest
import HackrNews

final class StoryPresentationTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages upon creation")
    }
    
    // MARK: - Helpers
    private func makeSUT() -> (StoryPresenter, StoryViewSpy){
        let view = StoryViewSpy()
        let sut = StoryPresenter(view: view)
        return (sut, view)
    }
    
    private class StoryViewSpy {
        private(set) var messages = [Any]()
    }
}
