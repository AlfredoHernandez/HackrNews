//
//  LocalHackrStoryLoader.swift
//  HackrNews
//
//  Created by Jesús Alfredo Hernández Alarcón on 14/02/21.
//

import Foundation

public protocol HackrStoryCache {
    typealias SaveResult = Result<Void, Error>
    func save(_ story: Story, completion: @escaping (SaveResult) -> Void)
}
