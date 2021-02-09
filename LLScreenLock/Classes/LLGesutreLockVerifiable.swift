//
//  LLGesutreLockVerifiable.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/8.
//  
//

import Foundation

public protocol LLGesutreLockVerifiable {
    
    /// 验证路径是否正确
    /// - Parameter indexs: 路径索引数组
    func verify(path indexs: [Int]) -> Bool
    
    /// 写入验证数据
    func change(path indexs: [Int])
    
    /// 关闭手势锁
    func close()
    
    /// 是否开启
    var isOpen: Bool { get }
}


public struct LLGesutreLockVerify: LLGesutreLockVerifiable {
    
    let verifyKey = "6787fad1b0a34c8fd48a574055487901"
    
    public var isOpen: Bool { (UserDefaults.standard.value(forKey: verifyKey) as? String ?? "").count > 0 }
    
    public func verify(path indexs: [Int]) -> Bool {
        return encrypt(path: indexs) == UserDefaults.standard.value(forKey: verifyKey) as? String ?? ""
    }
    
    /// 写入验证数据
    public func change(path indexs: [Int]) {
        let password = encrypt(path: indexs)
        UserDefaults.standard.setValue(password, forKey: verifyKey)
        UserDefaults.standard.synchronize()
    }
    
    public func close() {
        UserDefaults.standard.setValue(nil, forKey: verifyKey)
    }
    
    /// 对路径进行编码转换
    /// - Parameter indexs: 路径数组
    /// - Returns: 编码结果
    public func encrypt(path indexs: [Int]) -> String {
        return indexs.map { "\($0)" }.reduce("", +).md5
    }
}
