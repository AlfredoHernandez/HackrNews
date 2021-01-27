//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import UIKit

public class StoryViewController: UITableViewController {
    private var story: StoryDetail?
    private var storyCellController: StoryCellController?

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
        storyCellController = StoryCellController(model: story!)
        return storyCellController!.view()
    }
}
