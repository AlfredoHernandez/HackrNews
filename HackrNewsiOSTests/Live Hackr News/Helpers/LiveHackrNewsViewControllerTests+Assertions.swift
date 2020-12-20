//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import XCTest

extension LiveHackrNewsViewControllerTests {
    func assertThat(
        _ sut: LiveHackrNewsViewController,
        hasViewConfiguredFor model: LiveHackrNew,
        at index: Int,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let view = sut.liveHackrNewView(for: index)
        guard let cell = view as? LiveHackrNewCell else {
            return XCTFail("Expected \(LiveHackrNewCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        XCTAssertEqual(
            cell.cellId,
            model.id,
            "Expected to be id #\(model.id) for cell, but got \(cell.cellId) instead.",
            file: file,
            line: line
        )
    }

    func assertThat(
        _ sut: LiveHackrNewsViewController,
        isRendering liveHackerNews: [LiveHackrNew],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedLiveHackrNewsViews() == liveHackerNews.count else {
            return XCTFail(
                "Expected \(liveHackerNews.count) news, got \(sut.numberOfRenderedLiveHackrNewsViews()) instead.",
                file: file,
                line: line
            )
        }
        liveHackerNews.enumerated().forEach { index, new in
            assertThat(sut, hasViewConfiguredFor: new, at: index, file: file, line: line)
        }
    }
}
