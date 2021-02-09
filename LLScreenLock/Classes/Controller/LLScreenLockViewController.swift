//
//  LLScreenLockViewController.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/7.
//  
//

import UIKit

public class LLScreenLockViewController: UIViewController {
    
    var windowHolder: UIWindow?
    
    let types: [LLScreenLock.LockType]
    
    init(_ types: [LLScreenLock.LockType], window: UIWindow) {
        self.windowHolder = window
        self.types = types
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 手势密码视图
    private lazy var gestureLockView = LLGestureLockView(delegate: self)

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    deinit {
        print(#function)
    }
    // MARK: UI
    
    func setupUI() {
        view.backgroundColor = LLScreenLock.backgroundColor
        view.addSubview(gestureLockView)
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.1, delay: 1.0, options: .curveLinear) {
            self.windowHolder?.alpha = 0.0
        } completion: { (finished) in
            self.windowHolder = nil
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.view.layoutSubviews()
        gestureLockView.frame = view.bounds
    }

    lazy var stepQueue: LLGestureLock.OperationStepQueue = {
        guard let operation = types.first(where: { $0 != .biometrics }) else {
            return unlockQueue
        }
        switch operation {
        case .gesture(let op):
            switch op {
            case .new: return newSetQueue
            case .unlock: return unlockQueue
            case .reset: return resetQueue
            case .close: return closeQueue
            }
        default:
            return unlockQueue
        }
    }()
}

extension LLScreenLockViewController: LLGestureLockViewDelegate {

    func drawPathFinished(path indexs: [Int]) {
        stepQueue.nextStep(indexs)
    }
}

extension LLScreenLockViewController {
    
    func resetStepQueue(queue: LLGestureLock.OperationStepQueue?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gestureLockView.status = .normal
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
                self?.dismiss()
            } else {
                self?.gestureLockView.status = .failed
                self?.resetStepQueue(queue: self?.unlockQueue)
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
    
    /// 解锁操作队列
    private var closeQueue: LLGestureLock.OperationStepQueue {
        let queue = LLGestureLock.OperationStepQueue(complete: { [weak self] (finished, indexs) in
            if finished {
                self?.gestureLockView.status = .success
                LLScreenLock.gestureLockVerify.close()
                self?.dismiss()
            } else {
                self?.gestureLockView.status = .failed
                self?.resetStepQueue(queue: self?.unlockQueue)
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
                self?.dismiss()
                LLScreenLock.gestureLockVerify.change(path: indexs)
            } else {
                self?.gestureLockView.status = .failed
                self?.resetStepQueue(queue: self?.newSetQueue)
            }
        })
        
        /// 第一遍输入
        var firstIndexs: [Int]? = nil
        queue.queue.append(LLGestureLock.StepOperation(operate: { [weak self] (indexs) -> LLGestureLock.OperationResult in
            firstIndexs = indexs
            self?.gestureLockView.status = .working
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.gestureLockView.status = .normal
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
                self?.resetStepQueue(queue: self?.resetQueue)
            }
        })
        /// 验证
        queue.queue.append(LLGestureLock.StepOperation(operate: { [weak self] (indexs) in
            if LLScreenLock.gestureLockVerify.verify(path: indexs) {
                self?.gestureLockView.status = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.gestureLockView.status = .normal
                    self?.gestureLockView.resetPath()
                }
                return .none
            } else {
                self?.resetStepQueue(queue: self?.resetQueue)
                return .failed
            }
        }))
        
        /// 第一遍输入
        var firstIndexs: [Int]? = nil
        queue.queue.append(LLGestureLock.StepOperation(operate: { [weak self] (indexs) -> LLGestureLock.OperationResult in
            firstIndexs = indexs
            self?.gestureLockView.status = .working
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.gestureLockView.status = .normal
                self?.gestureLockView.resetPath()
            }
            return .none
        }))
        /// 第二遍输入
        queue.queue.append(LLGestureLock.StepOperation(operate: { [weak self] (indexs) -> LLGestureLock.OperationResult in
            if firstIndexs == indexs {
                self?.gestureLockView.status = .success
                return .complete
            } else {
                self?.gestureLockView.status = .failed
                return .failed
            }
        }))
        return queue
    }
}
