//
//  UIColor+Extensions.swift
//  Pods
//
//  Created by Caesar Wirth on 10/9/16.
//
//

import UIKit

internal extension UIColor {
    convenience init(rgb: UInt) {
       self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
    
    convenience init(rgb: UInt, alpha: CGFloat) {
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: alpha)
    }

    /// Hexadecimal representation of the UIColor.
    /// For example, UIColor.blackColor() becomes "#000000".
    var hex: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)

        let r = Int(255.0 * red)
        let g = Int(255.0 * green)
        let b = Int(255.0 * blue)

        let str = String(format: "#%02x%02x%02x", r, g, b)
        return str
    }

}
