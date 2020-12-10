//
//  StoryItemMapper.swift
//  HackrNews
//
//  Created by Jesús Alfredo Hernández Alarcón on 10/12/20.
//

import Foundation

public class StoryItemMapper {
    enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(data: Data, response: HTTPURLResponse) throws {
        if response.statusCode != 200 {
            throw Error.invalidData
        }
        guard let _ = try? JSONSerialization.jsonObject(with: data) else {
            throw Error.invalidData
        }
    }
}

