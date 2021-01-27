//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class StoryViewController: UITableViewController {
    private var locale = Locale.current
    private var calendar = Calendar(identifier: .gregorian)
    private var story: StoryDetail?

    public convenience init(story: StoryDetail) {
        self.init()
        self.story = story
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(StoryDetailCell.self, forCellReuseIdentifier: "StoryDetailCell")
        tableView.reloadData()
    }

    override public func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        1
    }

    override public func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = StoryDetailCell()
        cell.titleLabel.text = story?.title
        cell.authorLabel.text = story?.author
        cell.scoreLabel.text = "\(story!.score) points"
        cell.commentsLabel.text = "\(story!.totalComments) comments"
        cell.createdAtLabel.text = format(from: story?.createdAt ?? Date())
        cell.urlLabel.text = story?.url.host
        return cell
    }

    private func format(from date: Date) -> String? {
        let dateFormatter = RelativeDateTimeFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        return dateFormatter.string(for: date)
    }
}
