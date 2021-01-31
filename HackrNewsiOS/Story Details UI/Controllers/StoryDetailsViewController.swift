//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

public class StoryDetailsViewController: UITableViewController {
    private(set) var storyCellController: StoryCellController?

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
        section == 0 ? storyCells : 0
    }

    private var storyCells: Int {
        storyCellController?.bodyText != nil ? 2 : 1
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt index: IndexPath) -> UITableViewCell {
        if index.section == 0 {
            if index.row == 0 {
                return storyCellController!.view(in: tableView)
            } else {
                let cell = UITableViewCell()
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.text = storyCellController?.bodyText
                cell.selectionStyle = .none
                return cell
            }
        } else {
            return storyCellController!.view(in: tableView)
        }
    }

    override public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? nil : "Comments"
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == .init(row: 0, section: 0) {
            storyCellController?.releaseCellForReuse()
        }
    }
}
