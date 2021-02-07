//
//  CGPoint.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/7.
//  
//

import Foundation


extension CGPoint {
    
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow(x - point.x, 2) + pow((y - point.y), 2))
    }
}
