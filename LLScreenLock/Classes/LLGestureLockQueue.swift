//
//  LLGestureLockQueue.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/18.
//  
//

import Foundation


class LLGestureLockQueue {
    
    var operations: [Operation] = []
    
    public func addOperation(operation: Operation) {
        operations.append(operation)
    }
    
    public func execute() {
//        guard let last = operations.popLast() else {
//            return
//        }
//        switch last {
//        case .verify(let complete):
//            complete("")
//        default:
//            break
//        }
    }
}

class LLGestureLockOperation {
    
//    var need = 4

    
    func t() {
//        check { () -> Operation<Int> in
//            Operation<Int>(value: 1)
//        }.wait { (value) -> Operation<[Int]> in
//            Operation<[Int]>(value: [value.value])
//        }
//        var ps: [String] = []
//        Workflow()
//            .draw { //(pwd) in
//                ps.append($0)
//            }
//            .wait()
//            .draw { //(pwd) in
//                ps.append($0)
//            }.complete {
//                
//            }
            
    }
    
}

public class Workflow {
    
//    let value: T
    
//    let actionView
    
    var values: [Bool] = []
    
    var tasks: [Task] = []
    
    public init() {}
    
    public func draw(task: @escaping ([Int]) -> Void) -> Workflow {
        tasks.append(.draw(task))
        return self
    }
    
    public func wait() -> Workflow {
        tasks.append(.wait)
        return self
    }
    
    func boolean(task: @escaping () -> Bool) -> Workflow {
//        tasks.append(.boolean(task))
        return self
    }
    
    public func complete(task: @escaping () -> Void) -> Workflow {
        tasks.append(.complete(task))
        return self
    }
    
    public func jump(step: Int) {
        let index = tasks.index(tasks.startIndex, offsetBy: step)
        tasks = Array(tasks[index...])
    }
    
    public func next(_ value: [Int]) {
        if tasks.count == 0 {
            return
        }
        let first = tasks.removeFirst()
        switch first {
        case .wait: return
        case .draw(let task):
            task(value)
        case .complete(let task):
            task()
        }
        next(value)
    }
    
    enum Task {
        case draw(([Int]) -> Void)
        case wait
//        case boolean(() -> Bool)
        case complete(() -> Void)
    }
}
