//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import XCTest

final class NewStoriesLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "NewStories"
        let bundle = Bundle(for: NewStoriesPresenter.self)
        assertLocalizedKeysAndValuesExists(in: bundle, table)
    }
}
