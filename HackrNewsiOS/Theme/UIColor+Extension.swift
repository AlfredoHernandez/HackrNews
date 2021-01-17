//
//  UIColor+Extension.swift
//  HackrNews
//
//  Created by Jesús Alfredo Hernández Alarcón on 17/01/21.
//

import UIKit

public extension UIColor {
    static var hackerNews: UIColor {
        UIColor(named: "HackrNews", in: Bundle(for: LiveHackrNewsViewController.self), compatibleWith: nil)!
    }
}
