//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

public class StoryBodyCellController {
    let body: String
    var cell: UITableViewCell?

    public init(body: String) {
        self.body = body
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.text = body.parseHTML()
        cell?.selectionStyle = .none
        return cell!
    }
}
