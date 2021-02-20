//
//  LLGestureLockIndicatorView.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/19.
//  
//

import UIKit

class LLGestureLockIndicatorView: UIView, UITableViewDelegate {
    
    private let stackView = UIStackView()
    
    private var items: [Int: LLGestureLockIndicatorItemView] = [:]
    
    private let rows: [LLGestureLockIndicatorRowView] = (0..<LLScreenLock.order).map { _ in
        LLGestureLockIndicatorRowView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = LLScreenLock.backgroundColor
        
        addSubview(stackView)
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.addArrangedSubviews(views: rows)
        /// 初始化 row
        
        var index: Int = 0
        rows.lazy.map(\.items).reduce([], +).forEach { (item) in
            items[index] = item
            index += 1
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
        let count = LLScreenLock.order * 2 - 1
        guard count > 0 else { return }
        stackView.spacing = bounds.width / CGFloat(count)
    }
    
    //
    
    /// 展示选中路径
    /// - Parameter indexs: 路径所以数组
    public func display(path indexs: [Int]) {
        items.values.forEach { $0.isSelected = false }
        Set(indexs).forEach { self.items[$0]?.isSelected = true }
    }
}

/// 行视图
fileprivate class LLGestureLockIndicatorRowView: UIStackView {
    
    var items: [LLGestureLockIndicatorItemView] = (0..<LLScreenLock.order).map {_ in
        LLGestureLockIndicatorItemView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        axis = .horizontal
        distribution = .fillEqually
        addArrangedSubviews(views: items)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let count = LLScreenLock.order * 2 - 1
        guard count > 0 else { return }
        spacing = bounds.width / CGFloat(count)
    }
}

/// 圆点视图
fileprivate class LLGestureLockIndicatorItemView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // 是否被选中
    public var isSelected: Bool = false {
        didSet {
            aLayer?.fillColor = isSelected ? LLScreenLock.workingPTColor.cgColor : LLScreenLock.normalPTColor.cgColor
        }
    }
    
    var aLayer: CAShapeLayer? { layer as? CAShapeLayer }
    
    // MARK: UI
    
    func setupUI() {
        aLayer?.fillColor = LLScreenLock.normalPTColor.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /// 确保是居中的正方形
        let size = min(bounds.width, bounds.height)
        let frame = CGRect(x: (bounds.width - size) / 2.0,
                             y: (bounds.height - size) / 2.0,
                             width: size,
                             height: size)
        aLayer?.path = UIBezierPath(ovalIn: frame).cgPath
    }
    
    override class var layerClass: AnyClass { CAShapeLayer.classForCoder() }
}

extension UIStackView {
    
    func addArrangedSubviews(views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
}
