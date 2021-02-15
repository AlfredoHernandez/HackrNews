//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

struct CachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)

    static func validate(_ timestamp: Date, against date: Date, maxCacheAgeInDays: Int) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false }
        return date < maxCacheAge
    }
}
