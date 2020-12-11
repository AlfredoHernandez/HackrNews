//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct NewStoriesErrorViewModel {
    public let message: String?

    public static var noErrorMessage: NewStoriesErrorViewModel {
        NewStoriesErrorViewModel(message: nil)
    }
}
