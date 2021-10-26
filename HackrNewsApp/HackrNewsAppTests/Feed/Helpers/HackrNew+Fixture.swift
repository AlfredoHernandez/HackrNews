//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

extension HackrNew {
    static func fixture(id: Int = Int.random(in: 0 ... 100)) -> HackrNew {
        HackrNew(id: id)
    }
}
