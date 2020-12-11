//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public class NewStoriesPresenter {
    public static var title: String {
        NSLocalizedString(
            "new_stories_title",
            tableName: "NewStories",
            bundle: Bundle(for: NewStoriesPresenter.self),
            value: "",
            comment: "New Stories title view"
        )
    }
}
