//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftSoup

extension String {
    func parseHTML() -> String {
        let paragraphIdentifier = "[P]"
        do {
            let html = try SwiftSoup.parse(self)
            _ = try html.select("p").before(paragraphIdentifier)
            let body = try html.text()
            return body.replacingOccurrences(of: "\(paragraphIdentifier) ", with: "\n\n")
        } catch {
            return self
        }
    }
}
