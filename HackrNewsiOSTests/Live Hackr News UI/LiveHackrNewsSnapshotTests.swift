//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import XCTest

final class LiveHackrNewsSnapshotTests: XCTestCase {
    func test_emptyStories() {
        let sut = makeSUT()

        sut.display(LiveHackrNewsErrorViewModel(message: .none))
        sut.display(emptyStories())

        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .light)), named: "empty_stories_light")
        assert(snapshot: sut.snapshot(for: .iPhone12Mini(style: .dark)), named: "empty_stories_dark")
    }

    // MARK: - Helpers

    private func makeSUT() -> LiveHackrNewsViewController {
        let controller = LiveHackrNewsViewController()
        controller.tableView.showsVerticalScrollIndicator = false
        return controller
    }

    private func emptyStories() -> [LiveHackrNewCellController] { [] }
}
