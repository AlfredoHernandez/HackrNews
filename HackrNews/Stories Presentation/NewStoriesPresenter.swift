//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public protocol NewStoriesView {}

public class NewStoriesPresenter {
    private let view: NewStoriesView

    public static var title: String {
        NSLocalizedString(
            "new_stories_title",
            tableName: "NewStories",
            bundle: Bundle(for: NewStoriesPresenter.self),
            value: "",
            comment: "New Stories title view"
        )
    }

    public init(view: NewStoriesView) {
        self.view = view
    }
}
