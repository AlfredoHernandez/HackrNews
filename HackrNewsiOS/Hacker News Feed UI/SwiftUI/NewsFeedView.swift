//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import SwiftUI
import Combine

public struct NewsFeedView: View {
    @ObservedObject var viewModel: NewsFeedViewModel
    
    public init(viewModel: NewsFeedViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            List(viewModel.news, id: \.id) { new in
                HackrNewCell(hackrNew: new)
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .refreshable {
                viewModel.refresh()
            }
            .navigationTitle(Text(HackrNewsFeedPresenter.topStoriesTitle))
        }.onAppear(perform: viewModel.load)
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NewsFeedView(
                viewModel: NewsFeedViewModel(
                    contentType: .topStories,
                    hackrNewsFeedloader: { Just([HackrNew(id: 1)]).setFailureType(to: Error.self).eraseToAnyPublisher() }
                )
            )
        }
    }
}
