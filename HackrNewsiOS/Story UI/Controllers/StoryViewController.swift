//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import UIKit

struct StoryDetail {
    let title: String
    let author: String
    let score: Int
    let createdAt: Date
    let totalComments: Int
    let comments: [Int]
    let url: URL
}

class StoryDetailCell: UITableViewCell {
    public private(set) var titleLabel = UILabel()
    public private(set) var urlLabel = UILabel()
    public private(set) var authorLabel = UILabel()
    public private(set) var scoreLabel = UILabel()
    public private(set) var commentsLabel = UILabel()
    public private(set) var createdAtLabel = UILabel()
}

class StoryViewController: UITableViewController {
    private var locale = Locale.current
    private var calendar = Calendar(identifier: .gregorian)
    private var story: StoryDetail?

    convenience init(story: StoryDetail) {
        self.init()
        self.story = story
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(StoryDetailCell.self, forCellReuseIdentifier: "StoryDetailCell")
        tableView.reloadData()
    }

    override func numberOfSections(in _: UITableView) -> Int {
        1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        1
    }

    override func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = StoryDetailCell()
        cell.titleLabel.text = story?.title
        cell.authorLabel.text = story?.author
        cell.scoreLabel.text = "\(story!.score) points"
        cell.commentsLabel.text = "\(story!.totalComments) comments"
        cell.createdAtLabel.text = format(from: story?.createdAt ?? Date())
        return cell
    }

    private func format(from date: Date) -> String? {
        let dateFormatter = RelativeDateTimeFormatter()
        dateFormatter.locale = locale
        dateFormatter.calendar = calendar
        return dateFormatter.string(for: date)
    }
}
