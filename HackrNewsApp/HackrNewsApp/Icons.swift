//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

enum IconState {
    case normal
    case selected
}

enum Icons {
    case top
    case new

    public func image(state: IconState) -> UIImage {
        switch (self, state) {
        case (.top, .normal):
            return UIImage(systemName: "newspaper")!
        case (.top, .selected):
            return UIImage(systemName: "newspaper.fill")!
        case (.new, .normal):
            return UIImage(systemName: "clock")!
        case (.new, .selected):
            return UIImage(systemName: "clock.fill")!
        }
    }
}
