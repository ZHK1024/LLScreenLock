//
//  UIColor.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/7.
//  
//

import UIKit

extension UIColor {
    
    static func rgb(_ hex: Int) -> UIColor {
        .rgb(CGFloat((hex & 0xff0000) >> 16),
             CGFloat((hex & 0x00ff00) >> 8),
             CGFloat((hex & 0x0000ff)),
             1.0)
    }
    
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        .init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
    }
}
