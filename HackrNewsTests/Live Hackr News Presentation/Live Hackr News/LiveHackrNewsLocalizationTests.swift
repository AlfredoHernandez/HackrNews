//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LiveHackrNewsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "HackrNewsFeed"
        let bundle = Bundle(for: HackrNewsFeedPresenter.self)
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
}
