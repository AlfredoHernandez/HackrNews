//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

public class StoryDetailsViewController: UITableViewController {
    private var storyCellController: StoryCellController?

    convenience init(storyCellController: StoryCellController) {
        self.init()
        self.storyCellController = storyCellController
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.register(StoryDetailCell.self, forCellReuseIdentifier: "StoryDetailCell")
        tableView.reloadData()
    }

    override public func numberOfSections(in _: UITableView) -> Int { 2 }

    override public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return storyCellController?.bodyText != nil ? 2 : 1
        } else {
            return 0
        }
    }

    override public func tableView(_: UITableView, cellForRowAt index: IndexPath) -> UITableViewCell {
        if index.section == 0 {
            if index.row == 0 {
                return storyCellController!.view()
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = storyCellController?.bodyText
                cell.selectionStyle = .none
                return cell
            }
        } else {
            return storyCellController!.view()
        }
    }

    override public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? nil : "Comments"
    }
}
