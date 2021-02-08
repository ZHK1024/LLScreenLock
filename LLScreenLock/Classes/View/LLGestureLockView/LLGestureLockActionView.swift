//
//  LLGestureLockActionView.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/8.
//  
//

import UIKit

protocol LLGestureLockActionViewDelegate: class {
    
    func drawPathFinished(path indexs: [Int])
}

class LLGestureLockActionView: UIView {
    
    /// 委托代理对象
    weak var delegate: LLGestureLockActionViewDelegate?
    
    /// 当前校验状态
    public var status: LLScreenLock.Status = .normal {
        didSet {
            unselectedItems.forEach { $0.item.status = .normal }
            selectedItems.forEach { $0.item.status = status }
            lineLayer.strokeColor = status.statusColors.lc.cgColor
        }
    }
    
    /// 纵向排列视图
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    /// 行级视图列表
    private let stackRows: [LLGestureLockActionRowView] = (0..<LLScreenLock.order).map {
        LLGestureLockActionRowView(row: $0)
    }
    
    /// 手势路径绘制层
    private let lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = LLScreenLock.pathLineColor.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = LLScreenLock.pathLineWidth
        layer.lineJoin = .round
        return layer
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: UI
    private func setupUI() {
        layer.addSublayer(lineLayer)
        addSubview(stackView)
        stackView.frame = UIScreen.main.bounds
        stackRows.forEach { stackView.addArrangedSubview($0) }
        
        /// 添加手势 (绘制手势密码)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        addGestureRecognizer(pan)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineLayer.frame = bounds
        
        let size = CGFloat.minimum(bounds.width, bounds.height)
        stackView.frame = CGRect(x: 0.0, y: 0.0, width: size, height: size)
        stackView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let row = (LLScreenLock.order - 1)
        guard row > 0 else { return }
        stackView.spacing = size * 0.375 / CGFloat(row)
        
        // 刷新 item 的位置信息
        initItemsInfo()
    }
    
    // MARK: Action
    
    @objc func panAction(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            initVerifyData()
        case .changed:
            let locaton =  pan.location(in: self)
            findSelectedItem(location: locaton)
            drawPathLine(location: locaton)
        case .cancelled, .ended, .failed:
            drawPathLine(location: nil)
            delegate?.drawPathFinished(path: selectedItems.map(\.item.index))
        default: break
        }
    }

    // MARK: Select
    
    typealias SelectionInfo = (item: LLGestureLockActionRowItemView, center: CGPoint)
    
    /// 所有 item 信息的缓存
    private var allItemsInfo: [SelectionInfo] = []
    
    /// 当前被选中的 item 列表
    private var selectedItems: [SelectionInfo] = []
    
    /// 违背选中的 item 列表
    private var unselectedItems: [SelectionInfo] = []
    
    /// 园的半径, 用于判断是否被选中
    private var radius: CGFloat = 0.0
    
    /// 初始化 item 信息数据
    private func initItemsInfo() {
        allItemsInfo = stackRows.lazy.map(\.items).reduce([], +).map({ [unowned self] in
            SelectionInfo(item: $0, center: $0.superview!.convert($0.center, to: self))
        })
        radius = (allItemsInfo.first?.item.bounds.width ?? 0.0) / 2
    }
    
    /// 初始化校验数据
    private func initVerifyData() {
        selectedItems = []
        unselectedItems = allItemsInfo
    }
    
    /// 查找新被选中的 item
    private func findSelectedItem(location: CGPoint) {
        guard let index = unselectedItems.firstIndex(where: { $0.center.distance(to: location) < radius }) else {
            return
        }
        /// 如果可重复选择, 则直接把选中的 item 加入选中列表
        /// 否则在未选择数组中删除选中的 item, 然后加入被选中列表
        if LLScreenLock.repeatable {
            if unselectedItems[index].item.index == selectedItems.last?.item.index { return }
            selectedItems.append(unselectedItems[index])
        } else {
            selectedItems.append(unselectedItems.remove(at: index))
        }
    }
    
    /// 绘制选中的路径
    /// - Parameter location: 当前手势所在位置
    private func drawPathLine(location: CGPoint?) {
        if selectedItems.count == 0 { return }
        let path = UIBezierPath()
        path.move(to: selectedItems.first!.center)
        selectedItems[1..<selectedItems.count].forEach { path.addLine(to: $0.center) }
        
        /// 如果有传入 location, 则把 location 作为终点进行绘制
        if let endPoint = location {
            path.addLine(to: endPoint)
        }
        
        lineLayer.path = path.cgPath
    }
    
    // MARK: Public
    
    public func reset() {
        lineLayer.path = nil
    }
}
