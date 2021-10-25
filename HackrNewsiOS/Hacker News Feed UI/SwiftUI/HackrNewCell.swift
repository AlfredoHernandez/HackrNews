//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNews
import SwiftUI

struct HackrNewCell: View {
    let hackrNew: HackrNew

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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

struct HackrNewCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HackrNewCell(hackrNew: .init(id: 1))
                .previewLayout(.sizeThatFits)
            HackrNewCell(hackrNew: .init(id: 1))
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
}
