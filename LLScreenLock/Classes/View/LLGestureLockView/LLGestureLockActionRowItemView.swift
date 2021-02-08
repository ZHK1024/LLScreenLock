//
//  LLGestureLockActionRowItemView.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/8.
//  
//

import UIKit

///  item 视图
class LLGestureLockActionRowItemView: UIView {
    
    /// 背景
    private let backLayer = CAShapeLayer()
    
    /// 中心点
    private let pointLayer = CAShapeLayer()
    
    /// 状态
    public var status: LLScreenLock.Status = .normal {
        didSet {
            let statusColors = status.statusColors
            backLayer.fillColor = statusColors.bk.cgColor
            pointLayer.fillColor = statusColors.pt.cgColor
        }
    }
    
    /// 行内索引
    let index: Int
    
    init(index: Int) {
        self.index = index
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.addSublayer(backLayer)
        layer.addSublayer(pointLayer)
        
        status = .normal
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backLayer.frame = bounds
        let size = bounds.width * 0.35
        pointLayer.frame = CGRect(x: 0.0, y: 0.0, width: size, height: size)
        pointLayer.position = backLayer.position
        
        backLayer.path = UIBezierPath(roundedRect: backLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: backLayer.bounds.size).cgPath
        pointLayer.path = UIBezierPath(roundedRect: pointLayer.bounds, byRoundingCorners: .allCorners, cornerRadii: pointLayer.bounds.size).cgPath
    }
}
