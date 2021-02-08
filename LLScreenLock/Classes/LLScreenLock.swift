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
    
    /// 手势密码校验对象 (包含了加密解密以及校验相关逻辑, 支持自定义逻辑)
    public static var gestureLockVerify: LLGesutreLockVerifiable = LLGesutreLockVerify()
    
    // MARK: UI
    
    /// 背景颜色
    public static var backgroundColor: UIColor = .white
    
    /// 绘制路径颜色 (绘制中)
    public static var pathLineColor: UIColor = .systemBlue
    
    /// 普通状态颜色
    public static var normalPTColor: UIColor = .rgb(0xEAEDF6)
    
    /// 普通状态背景颜色
    public static var normalBKColor: UIColor = .clear
    
    /// 成功状态颜色
    public static var succesPTColor: UIColor = .systemGreen
    
    /// 成功状态背景颜色
    public static var succesBKColor: UIColor = UIColor.systemGreen.withAlphaComponent(0.3)
    
    /// 错误装颜色
    public static var failedPTColor: UIColor = .systemRed
    
    /// 错误状态背景颜色
    public static var failedBKColor: UIColor = UIColor.systemRed.withAlphaComponent(0.3)
    
    /// 绘制路径线条宽度
    public static var pathLineWidth: CGFloat = 6.0
    
}

extension LLScreenLock {
    
    public enum LockType: Equatable {
        case biolog
        case gesture(LLGestureLock.OperationType)
    }
    
    public static func lock(types: [LockType]) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = LLScreenLockViewController(types, window: window)
        window.makeKeyAndVisible()
    }
}


extension LLScreenLock {
    
    typealias StatusColors = (pt: UIColor, bk: UIColor, lc: UIColor)
    
    enum Status {
        case normal
        case success
        case failed
        
        /// 状态对应的 UIColor 对象
        var statusColors: StatusColors {
            switch self {
            case .normal: return StatusColors(pt: LLScreenLock.normalPTColor,
                                              bk: LLScreenLock.normalBKColor,
                                              lc: LLScreenLock.pathLineColor)
            case .success: return StatusColors(pt: LLScreenLock.succesPTColor,
                                               bk: LLScreenLock.succesBKColor,
                                               lc: LLScreenLock.succesPTColor)
            case .failed: return StatusColors(pt: LLScreenLock.failedPTColor,
                                              bk: LLScreenLock.failedBKColor,
                                              lc: LLScreenLock.failedPTColor)
            }
        }
    }
}
