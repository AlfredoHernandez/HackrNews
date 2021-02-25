//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class HackrNewsFeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: HackrNewsFeedRefreshController?
    private(set) var tableModel = [HackrNewFeedCellController]() {
        didSet {
            tableView.reloadData()
        }
    }

    public convenience init(refreshController: HackrNewsFeedRefreshController) {
        self.init()
        self.refreshController = refreshController
    }

    override public func viewDidLoad() {
        setLargeTitleDisplayMode(.always)
        tableView.prefetchDataSource = self
        tableView.register(HackrNewFeedCell.self, forCellReuseIdentifier: "HackrNewFeedCell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshController?.view
        fixNavigationBarSize(afterRefresh: false)
        refreshController?.refresh()
    }

    public func display(_ cellControllers: [HackrNewFeedCellController]) {
        fixNavigationBarSize(afterRefresh: true)
        tableModel = cellControllers
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        tableModel.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(forRowAt: indexPath).view(in: tableView)
    }

    override public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).didSelect()
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(at: indexPath)
    }

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> HackrNewFeedCellController {
        tableModel[indexPath.row]
    }

    private func cancelCellControllerLoad(at indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }

    private func fixNavigationBarSize(afterRefresh: Bool) {
        let top = tableView.adjustedContentInset.top
        let topSize = (refreshControl?.frame.maxY ?? 0.0) + top
        let totalTop = afterRefresh ? topSize + 100 : topSize
        tableView.setContentOffset(CGPoint(x: 0, y: -totalTop), animated: true)
    }

    public func scrollToTop() {
        if tableModel.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

extension HackrNewsFeedViewController: HackrNewsFeedErrorView {
    public func display(_: HackrNewsFeedErrorViewModel) {
        // TODO: Display error message
    }
}
