//
//  LLGestureLockActionRowView.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/8.
//  
//

import UIKit

/// 行级视图
class LLGestureLockActionRowView: UIStackView {
    
    /// 行索引
    let row: Int
    
    private lazy var rowItems: [LLGestureLockActionRowItemView] = (0..<LLScreenLock.order).map {
        LLGestureLockActionRowItemView(index: row * LLScreenLock.order + $0)
    }
    
    public var items: [LLGestureLockActionRowItemView] { rowItems }
    
    init(row: Int) {
        self.row = row
        super.init(frame: UIScreen.main.bounds)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        axis = .horizontal
        distribution = .fillEqually
        items.forEach { addArrangedSubview($0) }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let row = (LLScreenLock.order - 1)
        guard row > 0 else { return }
        spacing = max(bounds.width, bounds.height) / CGFloat(row) * 0.375
    }
}
