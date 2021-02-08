//
//  LLGestureLockView.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/7.
//  
//

import UIKit



protocol LLGestureLockViewDelegate: LLGestureLockActionViewDelegate {
    
//    func <#name#>(<#parameters#>) -> <#return type#>
    
}

class LLGestureLockView: UIView {
    
    /// 委托代理对象
    public weak var delegate: LLGestureLockViewDelegate? {
        didSet {
            actionView.delegate = delegate
        }
    }
    
    /// 当前校验状态
    public var status: LLScreenLock.Status = .normal {
        didSet { actionView.status = status }
    }
    
    /// 手势密码视图
    private let actionView = LLGestureLockActionView()
    
    init(delegate: LLGestureLockViewDelegate? = nil) {
        self.delegate = delegate
        actionView.delegate = delegate
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: UI
    
    func setupUI() {
        addSubview(actionView)
        actionView.frame = UIScreen.main.bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width * 0.7
        actionView.frame = CGRect(x: 0.0, y: 0.0, width: width, height: width)
        actionView.center = center
    }
    
    // MARK: Public
    
    /// 重置绘制的路径
    public func resetPath() {
        actionView.reset()
    }
}
