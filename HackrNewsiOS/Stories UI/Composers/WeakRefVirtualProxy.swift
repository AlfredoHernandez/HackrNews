//
//  WeakRef.swift
//  HackrNewsiOS
//
//  Created by Jesús Alfredo Hernández Alarcón on 17/12/20.
//

import Foundation

final class WeakRefVirtualProxy<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: LiveHackrNewsLoadingView where T: LiveHackrNewsLoadingView {
    func display(isLoading: Bool) {
        object?.display(isLoading: isLoading)
    }
}
