//
//  LLDefines.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/18.
//  
//

import Foundation


extension UIColor {
    
    static var random: UIColor {
        UIColor(red: .random(in: 0.0...1.0), green: .random(in: 0.0...1.0), blue: .random(in: 0.0...1.0), alpha: 1)
    }
}
