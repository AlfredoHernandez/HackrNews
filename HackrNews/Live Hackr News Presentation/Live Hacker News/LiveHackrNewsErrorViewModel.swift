//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct LiveHackrNewsErrorViewModel {
    public let message: String?

    public init(message: String?) {
        self.message = message
    }

    public static var noErrorMessage: LiveHackrNewsErrorViewModel {
        LiveHackrNewsErrorViewModel(message: nil)
    }
}
