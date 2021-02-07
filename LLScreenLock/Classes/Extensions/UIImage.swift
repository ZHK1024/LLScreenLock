//
//  UIImage.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/7.
//  
//

import UIKit

extension UIImage {
    
    convenience init?(ll_named name: String ) {
        self.init(named: Bundle(for: LLScreenLock.self).bundlePath + "/LLScreenLock.bundle/\(name)")
    }
}
