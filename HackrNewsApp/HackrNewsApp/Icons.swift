//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

enum IconState {
    case normal
    case selected
}

enum Icons {
    case news
    case new

    public func image(state: IconState) -> UIImage {
        switch (self, state) {
        case (.news, .normal):
            return UIImage(systemName: "newspaper")!
        case (.news, .selected):
            return UIImage(systemName: "newspaper.fill")!
        case (.new, .normal):
            return UIImage(systemName: "clock")!
        case (.new, .selected):
            return UIImage(systemName: "clock.fill")!
        }
    }
}
