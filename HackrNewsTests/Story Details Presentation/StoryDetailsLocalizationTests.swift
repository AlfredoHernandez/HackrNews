//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class StoryDetailsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "StoryDetails"
        let bundle = Bundle(for: StoryDetailsPresenter.self)
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
}
