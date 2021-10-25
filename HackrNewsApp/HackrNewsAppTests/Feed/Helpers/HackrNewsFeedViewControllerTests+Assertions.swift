//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS
import XCTest

extension HackrNewsFeedUIKitIntegrationTests {
    func assertThat(
        _ sut: HackrNewsFeedViewController,
        isRendering feed: [HackrNew],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard sut.numberOfRenderedHackrNewsFeedViews() == feed.count else {
            return XCTFail(
                "Expected \(feed.count) news, got \(sut.numberOfRenderedHackrNewsFeedViews()) instead.",
                file: file,
                line: line
            )
        }
    }
}
