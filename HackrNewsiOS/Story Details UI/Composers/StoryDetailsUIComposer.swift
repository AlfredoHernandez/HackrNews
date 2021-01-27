//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import Foundation
import HackrNews

public class StoryDetailsUIComposer {
    public static func composeWith(model: StoryDetail) -> StoryDetailsViewController {
        let storyCellController = StoryCellController(viewModel: StoryDetailsPresenter.map(model))
        let controller = StoryDetailsViewController(storyCellController: storyCellController)
        return controller
    }
}
