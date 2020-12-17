//
//  Copyright © 2020 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

public struct LiveHackrNewsErrorViewModel {
    public let message: String?

    public static var noErrorMessage: LiveHackrNewsErrorViewModel {
        LiveHackrNewsErrorViewModel(message: nil)
    }
}
