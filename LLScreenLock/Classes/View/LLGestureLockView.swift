//
//  LLGestureLockView.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/7.
//  
//

import UIKit

class LLGestureLockView: UIView {
    
    private let actionView = LLGestureLockActionView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
}


class LLGestureLockActionView: UIView {
    
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
        layer.strokeColor = UIColor.systemBlue.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 3.0
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
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(pan:)))
        addGestureRecognizer(pan)
        
//        backgroundColor = .systemGray
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
        
        print(bounds)
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
            lineLayer.path = nil
        default: break
        }
    }

    // MARK: Select
    
    typealias SelectionInfo = (item: LLGestureLockActionRowItemView, rect: CGRect, center: CGPoint)
    
    private var allItemsInfo: [SelectionInfo] = []
    
    /// 当前被选中的 item 列表
    private var selectedItems: [SelectionInfo] = []
    
    /// 违背选中的 item 列表
    private var unselectedItems: [SelectionInfo] = []
    
    private var distance: CGFloat = 0.0
    
    /// 初始化 item 信息数据
    private func initItemsInfo() {
        allItemsInfo = stackRows.lazy.map(\.items).reduce([], +).map({ [unowned self] in
            SelectionInfo(item: $0, rect: $0.convert($0.frame, to: self), center: $0.superview!.convert($0.center, to: self))
        })
        distance = (allItemsInfo.first?.item.bounds.width ?? 0.0) / 2
    }
    
    /// 初始化校验数据
    private func initVerifyData() {
        selectedItems = []
        unselectedItems = allItemsInfo
    }
    
    /// 查找新被选中的 item
    private func findSelectedItem(location: CGPoint) {
        guard let index = unselectedItems.firstIndex(where: { $0.center.distance(to: location) < distance }) else {
            return
        }
        /// 如果可重复选择, 则直接把选中的 item 加入选中列表
        /// 否则在未选择数组中删除选中的 item, 然后加入被选中列表
        if LLScreenLock.repeatable {
            selectedItems.append(unselectedItems[index])
        } else {
            selectedItems.append(unselectedItems.remove(at: index))
        }
    }
    
    /// 绘制选中的路径
    /// - Parameter location: 当前手势所在位置
    private func drawPathLine(location: CGPoint) {
        if selectedItems.count == 0 { return }
        let path = UIBezierPath()
        path.move(to: selectedItems.first!.center)
        selectedItems[1..<selectedItems.count].forEach { path.addLine(to: $0.center) }
        path.addLine(to: location)
        
        lineLayer.path = path.cgPath
    }
}

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
        spacing = 10.0
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
