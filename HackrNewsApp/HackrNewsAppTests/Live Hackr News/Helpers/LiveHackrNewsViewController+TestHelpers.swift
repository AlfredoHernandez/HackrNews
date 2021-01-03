//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNewsiOS
import UIKit

extension LiveHackrNewsViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }

    func simulateUserInitiatedLiveHackrNewsReload() {
        refreshControl?.simulatePullToRefresh()
    }

    func numberOfRenderedLiveHackrNewsViews() -> Int {
        tableView.numberOfRows(inSection: hackrNewsSection)
    }

    func liveHackrNewView(for row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: row, section: hackrNewsSection)
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }

    func simulateStoryNearViewVisible(at index: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: hackrNewsSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }

    func simulateStoryNotNearViewVisible(at index: Int) {
        simulateStoryNearViewVisible(at: index)

        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: hackrNewsSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }

    @discardableResult
    func simulateStoryViewVisible(at index: Int) -> LiveHackrNewCell? {
        liveHackrNewView(for: index) as? LiveHackrNewCell
    }

    func simulateTapOnStory(at index: Int) {
        let dl = tableView.delegate
        let indexPath = IndexPath(row: index, section: hackrNewsSection)
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    @discardableResult
    func simulateStoryViewNotVisible(at index: Int) -> LiveHackrNewCell? {
        let view = simulateStoryViewVisible(at: index)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: hackrNewsSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
        return view
    }

    var hackrNewsSection: Int { 0 }
}
