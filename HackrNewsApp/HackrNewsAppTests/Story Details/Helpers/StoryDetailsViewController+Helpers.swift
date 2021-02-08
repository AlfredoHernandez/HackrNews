//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

@testable import HackrNewsiOS
import UIKit

extension StoryDetailsViewController {
    var storyDetailsView: StoryDetailCell? {
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: detailSection)) as? StoryDetailCell
    }

    var storyTextView: UITableViewCell? {
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: detailSection))
    }

    @discardableResult
    func simulateStoryDetailViewVisible() -> StoryDetailCell? {
        storyDetailsView
    }

    func simulateStoryDetailViewNotVisible() {
        let delegate = tableView.delegate
        delegate?.tableView?(tableView, didEndDisplaying: storyDetailsView!, forRowAt: IndexPath(row: 0, section: detailSection))
    }

    var titleText: String? {
        storyDetailsView?.titleLabel.text
    }

    var authorText: String? {
        storyDetailsView?.authorLabel.text
    }

    var scoreText: String? {
        storyDetailsView?.scoreLabel.text
    }

    var commentsText: String? {
        storyDetailsView?.commentsLabel.text
    }

    var createdAtText: String? {
        storyDetailsView?.createdAtLabel.text
    }

    var urlText: String? {
        storyDetailsView?.urlLabel.text
    }

    var bodyText: String? {
        storyTextView?.textLabel?.text
    }

    var commentsTitle: String? {
        tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: commentsSection)
    }

    var detailViewIsReusable: Bool {
        storyCellController.cell == nil
    }

    func numberOfRenderedComments() -> Int {
        tableView.numberOfRows(inSection: commentsSection)
    }

    func commentView(at row: Int = 0) -> UITableViewCell? {
        let ds = tableView.dataSource
        return ds?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: commentsSection))
    }

    @discardableResult
    func simulateCommentViewVisible(at row: Int = 0) -> CommentCell? {
        guard numberOfRows(in: commentsSection) > row else {
            return nil
        }
        return commentView(at: row) as? CommentCell
    }

    func simulateCommentViewIsNearVisible(at row: Int = 0) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: commentsSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }

    func simulateCommentViewIsNotNearVisible(at row: Int = 0) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: commentsSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }

    @discardableResult
    func simulateCommentViewNotVisible(at row: Int = 0) -> CommentCell? {
        let view = simulateCommentViewVisible()
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: commentsSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
        return view
    }

    func simulateTapOnStoryDetailsView(at row: Int = 0) {
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: detailSection)
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    func simulateTapOnStoryDetailsBodyView() {
        simulateTapOnStoryDetailsView(at: 1)
    }

    func simulateTapOnCommentView(at row: Int = 0) {
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: commentsSection)
        delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }

    private var detailSection: Int { 0 }

    private var commentsSection: Int { 1 }
}

extension CommentCell {
    static var defaultAuthorText: String {
        "Lorem ipsum"
    }

    var authorText: String? {
        authorLabel.text
    }
}
