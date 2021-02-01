//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import XCTest

class CommentPresenter {
    init(view _: Any) {}
}

final class CommentPresentationTests: XCTestCase {
    func test_init_doesNotSendMessagesToView() {
        let view = CommentViewSpy()
        _ = CommentPresenter(view: view)

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages upon creation")
    }

    // MARK: - Helpers

    private class CommentViewSpy {
        var messages = [Any]()
    }
}
