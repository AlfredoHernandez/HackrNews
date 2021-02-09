//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class StoryDetailsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private let commentsSection = 1
    private let storySection = 0
    private var storyCell: IndexPath { IndexPath(row: 0, section: storySection) }
    private var storyBodyCell: IndexPath { IndexPath(row: 1, section: storySection) }
    private(set) var storyCellController: StoryCellController
    private let bodyCommentCellController: StoryBodyCellController?
    private var comments = [CommentCellController]() {
        didSet {
            tableView.reloadData()
        }
    }

    public init(storyCellController: StoryCellController, bodyCommentCellController: StoryBodyCellController?) {
        self.storyCellController = storyCellController
        self.bodyCommentCellController = bodyCommentCellController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setLargeTitleDisplayMode(.never)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.register(StoryDetailCell.self, forCellReuseIdentifier: "StoryDetailCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.prefetchDataSource = self
        tableView.delegate = self
    }

    override public func numberOfSections(in _: UITableView) -> Int { 2 }

    override public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? storyCells : comments.count
    }

    private var storyCells: Int {
        bodyCommentCellController != nil ? 2 : 1
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt index: IndexPath) -> UITableViewCell {
        switch index {
        case storyCell:
            return storyCellController.view(in: tableView)
        case storyBodyCell:
            return bodyCommentCellController!.view(in: tableView)
        default:
            return comments[index.row].view(in: tableView)
        }
    }

    override public func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? nil : StoryDetailsPresenter.title
    }

    override public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == storyCell {
            storyCellController.selection()
        }
    }

    override public func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case storySection:
            storyCellController.releaseCellForReuse()
        case commentsSection:
            cancelCellControllerLoad(at: indexPath)
        default:
            break
        }
    }

    public func display(_ comments: [CommentCellController]) {
        self.comments = comments
    }

    public func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(preloadCellController)
    }

    public func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func validateCommentInRange(at indexPath: IndexPath) -> Bool {
        (indexPath.section == commentsSection) && (comments.count > 0)
    }

    private func commentController(forRowAt indexPath: IndexPath) -> CommentCellController {
        comments[indexPath.row]
    }

    private func preloadCellController(at indexPath: IndexPath) {
        if validateCommentInRange(at: indexPath) {
            commentController(forRowAt: indexPath).preload()
        }
    }

    private func cancelCellControllerLoad(at indexPath: IndexPath) {
        if validateCommentInRange(at: indexPath) {
            commentController(forRowAt: indexPath).cancel()
        }
    }
}
