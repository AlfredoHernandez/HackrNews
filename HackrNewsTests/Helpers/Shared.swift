//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyID() -> Int {
    (1 ... 10).randomElement()!
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    private var cacheMaxAgeInDays: Int { 1 }

    private var storyCacheMaxAgeInMinutes: Int { 5 }

    func minusCacheMaxAge() -> Date {
        adding(days: -cacheMaxAgeInDays)
    }

    func minusStoryCacheMaxAge() -> Date {
        adding(min: -storyCacheMaxAgeInMinutes)
    }

    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .day, value: days, to: self)!
    }

    func adding(min: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .minute, value: min, to: self)!
    }

    func adding(seconds: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        calendar.date(byAdding: .second, value: seconds, to: self)!
    }
}
