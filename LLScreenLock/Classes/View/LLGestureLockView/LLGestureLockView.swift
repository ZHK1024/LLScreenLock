//
//  LLGestureLockView.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/7.
//  
//

import UIKit

protocol LLGestureLockViewDelegate: LLGestureLockActionViewDelegate {
    
}

class LLGestureLockView: LLBaseLockView {
    
    /// 委托代理对象
    public weak var delegate: LLGestureLockViewDelegate?
    
    /// 当前校验状态
    public var status: LLScreenLock.Status = .normal {
        didSet { actionView.status = status }
    }
    
    /// 顶部指示视图
    private let indicatorView = LLGestureLockIndicatorView()
    
    /// 手势密码视图
    private let actionView = LLGestureLockActionView()
    
    /// 标题
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 21.0)
        label.text = "请绘制手势密码"
        label.textColor = LLScreenLock.titleColor
        return label
    }()
    
    /// 提示语
    public let tipLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = LLScreenLock.tipsColor
        return label
    }()
    
    // MARK: Init
    
    init(_ delegate: LLGestureLockViewDelegate? = nil) {
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
        addSubview(titleLabel)
        addSubview(tipLabel)
        addSubview(indicatorView)
        addSubview(actionView)
        actionView.frame = UIScreen.main.bounds
        indicatorView.frame = CGRect(x: 100, y: 100, width: 60, height: 60)
        
        actionView.delegate = self
        
        titleLabel.text = "请绘制手势密码"
        tipLabel.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margin = bounds.width * 0.15
        actionView.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.width)
        actionView.contentInsets = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        if #available(iOS 11.0, *) {
            actionView.center = CGPoint(x: center.x, y: center.y + safeAreaInsets.top)
        } else {
            actionView.center = center
        }
        
        tipLabel.frame = CGRect(x: 0.0, y: actionView.frame.minY, width: bounds.width, height: 20)
        titleLabel.frame = CGRect(x: 0.0, y: tipLabel.frame.minY - 35, width: bounds.width, height: 20)
        
        indicatorView.frame = CGRect(x: 0.0, y: 0.0, width: 60, height: 60)
        indicatorView.center = CGPoint(x: bounds.midX, y: titleLabel.frame.minY - 30 - indicatorView.bounds.midY)
    }
    
    // MARK: Public
    
    /// 重置绘制的路径
    public func resetPath() {
        actionView.reset()
        indicatorView.display(path: [])
    }
}

extension LLGestureLockView: LLGestureLockActionViewDelegate {
    
    func drawPathFinished(path indexs: [Int]) {
        delegate?.drawPathFinished(path: indexs)
    }
    
    func drawPathChanged(path indexs: [Int]) {
        delegate?.drawPathChanged(path: indexs)
        indicatorView.display(path: indexs)
    }
    
}
