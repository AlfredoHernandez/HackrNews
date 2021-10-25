//
//  NewsFeedView.swift
//  HackrNewsiOS
//
//  Created by Jesús Alfredo Hernández Alarcón on 25/10/21.
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import SwiftUI
import HackrNews

struct HackrNewCell: View {
    let hackrNew: HackrNew
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            HStack {
                Text("by arkadiyt")
                    .foregroundColor(.secondary)
                Spacer()
                Text("1 hour ago")
                    .foregroundColor(.secondary)
            }
            Text("The FBI's internal guide for getting data from AT&T, T-Mobile, Verizon")
                .font(.title3)
            Text("www.vice.com")
            HStack {
                Text("460 points")
                Text("111 comments")
            }
        }.redacted(reason: .placeholder)
    }
}

struct NewsFeedView: View {
    let news: [HackrNew] = [
        .init(id: 1),
        .init(id: 2),
        .init(id: 3),
        .init(id: 4),
        .init(id: 5),
        .init(id: 6)
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
