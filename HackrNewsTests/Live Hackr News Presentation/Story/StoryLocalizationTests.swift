//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class StoryLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Story"
        let bundle = Bundle(for: StoryPresenter.self)
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
}
