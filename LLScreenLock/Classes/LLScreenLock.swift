//
//  ViewController.swift
//  LLScreenLock
//
//  Created by Ruris on 02/07/2021.
//  Copyright (c) 2021 Ruris. All rights reserved.
//

public class LLScreenLock {
    
    /// UIWindow 的 windowLevel
    public static var windowLevel = 1000
    
    /// 行列数量
    public static var order: Int = 3
    
    /// 是否可重复选择
    public static var repeatable: Bool = false
    
    /// 背景颜色
    public static var backgroundColor: UIColor = .white
    
    /// 普通状态颜色
    public static var normalPTColor: UIColor = .rgb(0xEAEDF6)
    
    /// 普通状态背景颜色
    public static var normalBKColor: UIColor = .white
    
    /// 成功状态颜色
    public static var succesPTColor: UIColor = .rgb(0x00ff00)
    
    /// 成功状态背景颜色
    public static var succesBKColor: UIColor = .rgb(0x00ff00)
    
    /// 错误装颜色
    public static var failedPTColor: UIColor = .systemRed
    
    /// 错误状态背景颜色
    public static var failedBKColor: UIColor = .systemRed
}


extension LLScreenLock {
    
    typealias StatusColors = (pt: UIColor, bk: UIColor)
    
    enum Status {
        case normal
        case success
        case failed
        
        var statusColors: StatusColors {
            switch self {
            case .normal: return StatusColors(pt: LLScreenLock.normalPTColor, bk: LLScreenLock.normalBKColor)
            case .success: return StatusColors(pt: LLScreenLock.succesPTColor, bk: LLScreenLock.succesBKColor)
            case .failed: return StatusColors(pt: LLScreenLock.failedPTColor, bk: LLScreenLock.failedBKColor)
            }
        }
    }
}
