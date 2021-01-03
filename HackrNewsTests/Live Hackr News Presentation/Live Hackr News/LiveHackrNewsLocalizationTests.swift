//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class LiveHackrNewsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "NewStories"
        let bundle = Bundle(for: LiveHackrNewsPresenter.self)
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
}
