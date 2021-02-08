//
//  LLGestureLockActionQueue.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/8.
//  
//

import Foundation

public struct LLGestureLock {}

extension LLGestureLock {
    
    struct StepOperation {
        
        typealias Operate = ([Int]) -> OperationResult
        
        let operate: Operate
        
        func execute(_ indexs: [Int]) -> OperationResult {
            operate(indexs)
        }
    }
}

extension LLGestureLock {
    
    class OperationStepQueue {
        
        var queue: [StepOperation] = []
        
        var complete: (Bool, [Int]) -> Void
        
        public func nextStep(_ indexs: [Int]) {
            if queue.count == 0 {
                return
            }
            switch queue.removeFirst().execute(indexs) {
            case .delay(let sec):
                DispatchQueue.main.asyncAfter(deadline: .now() + sec) {
                    self.nextStep(indexs)
                }
            case .complete:
                complete(true, indexs)
            case .failed:
                complete(false, indexs)
            case .none: break
            }
        }
        
        init(complete: @escaping (Bool, [Int]) -> Void) {
            self.complete = complete
        }
    }
}

extension LLGestureLock {
    
    enum OperationResult {
        case none
        case delay(TimeInterval)
        case complete
        case failed
    }
}


extension LLGestureLock {
    
    public enum OperationType {
        case unlock
        case reset
        case new
    }
}
