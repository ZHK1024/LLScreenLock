//
//  LLBiometricsLockView.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/9.
//  
//

import UIKit
import LocalAuthentication

protocol LLBiometricsLockViewDelegate: NSObject {
    
    /// 视图被点击
    func biometricsLockViewTouched()
}

class LLBiometricsLockView: LLBaseLockView {
    
    /// 代理对象
    public weak var delegate: LLBiometricsLockViewDelegate?
    
    /// 图标视图
    private let imageView = UIImageView()
    
    /// 图标名称
    public var iconName: String? {
        didSet {
            if let name = iconName {
                imageView.image = UIImage(ll_named: name)
            } else {
                imageView.image = nil
            }
        }
    }
    
    // MARK: Init
    
    init(_ delegate: LLBiometricsLockViewDelegate) {
        super.init(frame: .zero)
        setupUI()
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: UI
    
    private func setupUI() {
        backgroundColor = LLScreenLock.backgroundColor
        addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        imageView.addGestureRecognizer(tap)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width * 0.369
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        imageView.center = CGPoint(x: center.x, y: center.y - max(32.0, safeAreaInsets.top / 2.0))
    }
    
    // MARK: Action
    
    @objc private func tapAction() {
        delegate?.biometricsLockViewTouched()
    }
}
