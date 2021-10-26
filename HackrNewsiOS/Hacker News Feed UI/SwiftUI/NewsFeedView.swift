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
                    news: news,
                    contentType: .topStories,
                    hackrNewsFeedloader: { Just(news).setFailureType(to: Error.self).eraseToAnyPublisher() }
                )
            )
        }
    }
    
    static var news: [HackrNew] {
        [
            HackrNew(id: 1),
            HackrNew(id: 2),
            HackrNew(id: 3),
            HackrNew(id: 4),
        ]
    }
}
