//
//  LLScreenLockViewController.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/7.
//  
//

import UIKit

public class LLScreenLockViewController: UIViewController {
    
    /// UIWindow 持有对象, 防止释放
    private var windowHolder: UIWindow?
    
    /// 操作类型
    private let action: LLScreenLock.Action
    
    /// 认证类型
    private let type: LLScreenLock.`Type`
    
    /// 是否已经验证通过
    private var isVerified: Bool = false
    
    /// 标题字典
    private let titleInfo: [LLScreenLock.Action: String] = [
        .new: "开启",
        .unlock: "解锁",
        .reset: "重置",
        .close: "关闭"
    ]
    
    // MARK: Init
    
    init(_ action: LLScreenLock.Action, type: LLScreenLock.`Type`, window: UIWindow?) {
        self.windowHolder = window
        self.action = action
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 手势密码视图
    private lazy var gestureLockView = LLGestureLockView(self)
    
    ///  生物认证视图
    private lazy var biometricsLockView = LLBiometricsLockView(self)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch type {
        case .all, .biometrics:
            biometricsLockViewTouched()
        default: break
        }
    }
    
    #if DEBUG
    deinit {
        print(#function)
    }
    #endif
    
    // MARK: UI
    
    func setupUI() {
        view.backgroundColor = LLScreenLock.backgroundColor
        title = titleInfo[action]
        /// 视图
        switch type {
        case .gesture, .all:
            view.addSubview(gestureLockView)
        case .biometrics:
            view.addSubview(biometricsLockView)
        }
         
        /// 设置返回按钮
        switch action {
        case .new, .reset, .close:
            navigationItem.leftBarButtonItem =
                UIBarButtonItem(image: UIImage(ll_named: "back"), style: .done, target: self, action: #selector(back))
        case .unlock: break
        }
    }
    
    // MARK: Action
    
    @objc private func back() {
        if windowHolder == nil {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss()
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.view.layoutSubviews()
        switch type {
        case .gesture, .all:
            gestureLockView.frame = view.bounds
        case .biometrics:
            biometricsLockView.frame = view.bounds
        }
    }
    
    /// 页面消失
    /// - Parameter delay: 延迟时间
    @objc private func dismiss(_ delay: TimeInterval = 1.0) {
        if windowHolder == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            UIView.animate(withDuration: 0.1, delay: delay, options: .curveLinear) {
                self.windowHolder?.alpha = 0.0
            } completion: { (finished) in
                self.windowHolder = nil
            }
        }
    }
    
    /// 当前操作队列
    lazy var stepQueue: LLGestureLock.OperationStepQueue = {
        switch action {
        case .new:
            return newSetQueue
        case .unlock:
            return unlockQueue
        case .reset:
            return resetQueue
        case .close:
            return closeQueue
        }
    }()
}

extension LLScreenLockViewController: LLGestureLockViewDelegate {

    func drawPathFinished(path indexs: [Int]) {
        stepQueue.nextStep(indexs)
    }
    
    func drawPathChanged(path indexs: [Int]) {}
}

extension LLScreenLockViewController: LLBiometricsLockViewDelegate {
    
    func biometricsLockViewTouched() {
        let type = LLBiometricsLockVerify.verify { [weak self] (success, message) in
            if success {
                self?.dismiss(0.0)
            }
        }
        switch type {
        case .faceID:
            biometricsLockView.iconName = "FaceID"
        case .touchID:
            biometricsLockView.iconName = "TouchID"
        default:
            biometricsLockView.iconName = nil
        }
    }
}

extension LLScreenLockViewController {
    
    func resetStepQueue(queue: LLGestureLock.OperationStepQueue?, text: String? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gestureLockView.status = .normal
            self.gestureLockView.tipLabel.text = text
            self.gestureLockView.resetPath()
        }
        guard let newQueue = queue else { return }
        self.stepQueue = newQueue
    }
    
    /// 解锁操作队列
    private var unlockQueue: LLGestureLock.OperationStepQueue {
        let queue = LLGestureLock.OperationStepQueue(complete: { [weak self] (finished, indexs) in
            if finished {
                self?.gestureLockView.status = .success
                self?.gestureLockView.tipLabel.text = NSLocalizedString("解锁成功", comment: "解锁成功")
                self?.dismiss()
            } else {
                self?.gestureLockView.status = .failed
                self?.gestureLockView.tipLabel.text = NSLocalizedString("密码不正确", comment: "密码不正确")
                self?.resetStepQueue(queue: self?.unlockQueue, text: "请重新绘制密码")
            }
        })
        queue.queue.append(LLGestureLock.StepOperation(operate: { (indexs) in
            if LLScreenLock.gestureLockVerify.verify(path: indexs) {
                return .complete
            } else {
                return .failed
            }
        }))
        return queue
    }
    
    /// 关闭操作队列
    private var closeQueue: LLGestureLock.OperationStepQueue {
        let queue = LLGestureLock.OperationStepQueue(complete: { [weak self] (finished, indexs) in
            if finished {
                self?.gestureLockView.status = .success
                self?.gestureLockView.tipLabel.text = NSLocalizedString("关闭成功", comment: "关闭成功")
                LLScreenLock.gestureLockVerify.close()
                self?.dismiss()
            } else {
                self?.gestureLockView.status = .failed
                self?.gestureLockView.tipLabel.text = NSLocalizedString("密码不正确", comment: "密码不正确")
                self?.resetStepQueue(queue: self?.closeQueue, text: "请重新绘制密码")
            }
        })
        queue.queue.append(LLGestureLock.StepOperation(operate: { (indexs) in
            if LLScreenLock.gestureLockVerify.verify(path: indexs) {
                return .complete
            } else {
                return .failed
            }
        }))
        return queue
    }
    
    /// 新建队列
    private var newSetQueue: LLGestureLock.OperationStepQueue {
        let queue = LLGestureLock.OperationStepQueue(complete: { [weak self] (finished, indexs) in
            if finished {
                self?.gestureLockView.status = .success
                self?.gestureLockView.tipLabel.text = "密码设置成功"
                self?.dismiss()
                LLScreenLock.gestureLockVerify.change(path: indexs)
            } else {
                self?.gestureLockView.status = .failed
                self?.gestureLockView.tipLabel.text = "两次绘制密码不同"
                self?.resetStepQueue(queue: self?.newSetQueue, text: "请重新绘制密码")
            }
        })
        
        /// 第一遍输入
        var firstIndexs: [Int]? = nil
        queue.queue.append(LLGestureLock.StepOperation(operate: { [weak self] (indexs) -> LLGestureLock.OperationResult in
            firstIndexs = indexs
            self?.gestureLockView.status = .working
            self?.gestureLockView.tipLabel.text = "绘制完成"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.gestureLockView.status = .normal
                self?.gestureLockView.tipLabel.text = NSLocalizedString("请再次绘制确认密码", comment: "请再次绘制确认密码")
                self?.gestureLockView.resetPath()
            }
            return .none
        }))
        /// 第二遍输入
        queue.queue.append(LLGestureLock.StepOperation(operate: { (indexs) -> LLGestureLock.OperationResult in
            if firstIndexs == indexs {
                return .complete
            } else {
                return .failed
            }
        }))
        return queue
    }
    
    /// 重置密码操作队列
    private var resetQueue: LLGestureLock.OperationStepQueue {
        let queue = LLGestureLock.OperationStepQueue(complete: { [weak self] (finished, indexs) in
            if finished {
                self?.gestureLockView.status = .success
                self?.dismiss()
                LLScreenLock.gestureLockVerify.change(path: indexs)
            } else {
                self?.gestureLockView.status = .failed
                self?.resetStepQueue(queue: self?.resetQueue, text: "请重新绘制密码")
            }
        })
        if isVerified == false {
            /// 验证
            queue.queue.append(LLGestureLock.StepOperation(operate: { [weak self] (indexs) in
                if LLScreenLock.gestureLockVerify.verify(path: indexs) {
                    self?.gestureLockView.status = .success
                    self?.gestureLockView.tipLabel.text = "验证成功"
                    /// 设置状态, 标记本次已经验证通过, 无需再次进行验证
                    self?.isVerified = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self?.gestureLockView.status = .normal
                        self?.gestureLockView.tipLabel.text = "请绘制新密码"
                        self?.gestureLockView.resetPath()
                    }
                    return .none
                } else {
                    self?.resetStepQueue(queue: self?.resetQueue)
                    self?.gestureLockView.tipLabel.text = "密码不正确"
                    return .failed
                }
            }))
        }
        
        /// 第一遍输入
        var firstIndexs: [Int]? = nil
        queue.queue.append(LLGestureLock.StepOperation(operate: { [weak self] (indexs) -> LLGestureLock.OperationResult in
            firstIndexs = indexs
            self?.gestureLockView.status = .working
            self?.gestureLockView.tipLabel.text = "绘制完成"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.gestureLockView.status = .normal
                self?.gestureLockView.tipLabel.text = "请再次绘制确认密码"
                self?.gestureLockView.resetPath()
            }
            return .none
        }))
        /// 第二遍输入
        queue.queue.append(LLGestureLock.StepOperation(operate: { [weak self] (indexs) -> LLGestureLock.OperationResult in
            if firstIndexs == indexs {
                self?.gestureLockView.tipLabel.text = "密码修改成功"
                self?.gestureLockView.status = .success
                return .complete
            } else {
                self?.gestureLockView.status = .failed
                self?.gestureLockView.tipLabel.text = "新密码绘制不一致"
                return .failed
            }
        }))
        return queue
    }
}
