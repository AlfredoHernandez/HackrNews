//
//  Copyright © 2021 Jesús Alfredo Hernández Alarcón. All rights reserved.
//

import HackrNewsiOS

extension CommentCell {
    static var defaultAuthorText: String {
        "Lorem ipsum"
    }

    var authorText: String? {
        authorLabel.text
    }

    var createdAtText: String? {
        createdAtLabel.text
    }

    var bodyText: String? {
        bodyLabel.text
    }
}
