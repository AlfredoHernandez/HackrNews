//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import SwiftUI

struct NewsFeedView: View {
    let news: [HackrNew] = [
        .init(id: 1),
        .init(id: 2),
        .init(id: 3),
        .init(id: 4),
        .init(id: 5),
        .init(id: 6),
    ]
    var body: some View {
        NavigationView {
            List(news, id: \.id) { new in
                HackrNewCell(hackrNew: new)
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .navigationTitle(Text(HackrNewsFeedPresenter.topStoriesTitle))
        }
    }
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView()
    }
}
