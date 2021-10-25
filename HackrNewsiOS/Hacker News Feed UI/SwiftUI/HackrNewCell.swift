//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import SwiftUI

struct HackrNewCell: View {
    let hackrNew: HackrNew
    @State var isLoading = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("alfredohdz")
                    .foregroundColor(.secondary)
                Spacer()
                Text("1 day ago")
                    .foregroundColor(.secondary)
            }
            Text("The FBI's internal guide for getting data from AT&T, T-Mobile, Verizon")
                .bold()
            Text("www.alfredohdz.io")
            HStack {
                Text("100 points")
                Text("999 comments")
            }
        }.redacted(reason: isLoading ? .placeholder : .privacy)
    }
}

struct HackrNewCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HackrNewCell(hackrNew: .init(id: 1))
                .previewLayout(.sizeThatFits)
            HackrNewCell(hackrNew: .init(id: 1), isLoading: true)
                .previewLayout(.sizeThatFits)
            HackrNewCell(hackrNew: .init(id: 1))
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
}
