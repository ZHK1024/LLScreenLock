//
//  String.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/8.
//  
//

import Foundation
import CommonCrypto

extension String {
    
    /// 计算字符串的 md5 字符串
    public var md5: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
}
