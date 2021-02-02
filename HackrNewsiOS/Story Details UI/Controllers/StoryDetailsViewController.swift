//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class StoryDetailsViewController: UITableViewController {
    private var detailsSection: Int { 0 }
    private var storyCell: IndexPath { IndexPath(row: 0, section: detailsSection) }
    private var storyBodyCell: IndexPath { IndexPath(row: 1, section: detailsSection) }
    private(set) var storyCellController: StoryCellController
    private var comments = [CommentCellController]() {
        didSet {
            tableView.reloadData()
        }
    }

    public init(storyCellController: StoryCellController) {
        self.storyCellController = storyCellController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(StoryDetailCell.self, forCellReuseIdentifier: "StoryDetailCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.reloadData()
    }

    override public func numberOfSections(in _: UITableView) -> Int { 2 }

    override public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? storyCells : comments.count
    }

    private var storyCells: Int {
        storyCellController.bodyText != nil ? 2 : 1
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt index: IndexPath) -> UITableViewCell {
        switch index {
        case storyCell:
            return storyCellController.view(in: tableView)
        case storyBodyCell:
            return bodyCell(in: tableView)
        default:
            return comments[index.row].view(in: tableView)
        }
    }

    override public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? nil : StoryDetailsPresenter.title
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == .init(row: 0, section: 0) {
            storyCellController.releaseCellForReuse()
        }
    }

    public func display(_ comments: [CommentCellController]) {
        self.comments = comments
    }

    private func bodyCell(in tableView: UITableView) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell()
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = storyCellController.bodyText
        cell.selectionStyle = .none
        return cell
    }
}
