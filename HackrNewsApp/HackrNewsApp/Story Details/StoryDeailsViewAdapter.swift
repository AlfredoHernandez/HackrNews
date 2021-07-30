//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import HackrNewsiOS

class StoryDeailsViewAdapter: ResourceView {
    weak var controller: CommentCellController?
    typealias ResourceViewModel = CommentViewModel

    func display(_ viewModel: ResourceViewModel) {
        controller?.display(viewModel)
    }

    init(controller: CommentCellController) {
        self.controller = controller
    }
}
