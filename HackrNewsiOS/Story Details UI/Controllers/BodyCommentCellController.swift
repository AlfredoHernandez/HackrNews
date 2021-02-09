//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftSoup
import UIKit

public class BodyCommentCellController {
    let body: String
    var cell: UITableViewCell?

    public init(body: String) {
        self.body = body
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.text = parse(content: body)
        cell?.selectionStyle = .none
        return cell!
    }

    private func parse(content: String) -> String {
        let paragraphIdentifier = "[P]"
        do {
            let html = try SwiftSoup.parse(content)
            _ = try html.select("p").before(paragraphIdentifier)
            let body = try html.text()
            return body.replacingOccurrences(of: "\(paragraphIdentifier) ", with: "\n\n")
        } catch {
            return content
        }
    }
}
