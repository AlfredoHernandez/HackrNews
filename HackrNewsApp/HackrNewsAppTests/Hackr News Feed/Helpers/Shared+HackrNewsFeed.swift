//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews

func uniqueFeed() -> [HackrNew] {
    [HackrNew(id: Int.random(in: 0 ... 100)), HackrNew(id: Int.random(in: 0 ... 100)), HackrNew(id: Int.random(in: 0 ... 100))]
}
