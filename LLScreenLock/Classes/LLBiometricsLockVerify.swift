//
//  LLBiometricsLockVerify.swift
//  LLScreenLock
//
//  Created by ZHK on 2021/2/20.
//  
//

import LocalAuthentication

struct LLBiometricsLockVerify {
    
    typealias Complete = (Bool, String?) -> Void
    
    /// 是生物识别认证否开启字段名
    private static let kBiometricsLockOpenKey = "651F1BBD2F04FAFF"
    
    /// 验证是否开启
    public static var isOpen: Bool {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kBiometricsLockOpenKey)
        }
        get {
            UserDefaults.standard.value(forKey: kBiometricsLockOpenKey) as? Bool ?? false
        }
    }
    
    /// 进行生物认证
    /// - Parameter block: 结果
    static public func verify(complete: @escaping Complete) -> LABiometryType {
        biometricsEnable { (context, message) in
            if context != nil {
                authentication(context: context!) { (success) in
                    complete(success, nil)
                }
            } else {
                complete(false, message)
            }
        }
    }
    
    /// 生物认证是否可用
    /// - Parameter block: 查询回调
    /// - Returns: 可用的生物认证类型
    static public func biometricsEnable(block: (LAContext?, String?) -> Void) -> LABiometryType {
        let context = LAContext()
        var error: NSError? = nil
        /// 判断
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            block(context, nil)
            return context.biometryType
        } else {
            var message: String = "生物认证不可用"
            if let aerror = error {
                switch Int32(aerror.code) {
                case kLAErrorInvalidContext:    // 实例化的 LAContext 对象失效
                    message = NSLocalizedString("LAContext 对象失效", comment: "LAContext 对象失效")
                case kLAErrorPasscodeNotSet:    // 设备上没有设置密码 (数字密码)
                    message = NSLocalizedString("未设置设备密码", comment: "未设置设备密码")
                case kLAErrorTouchIDNotEnrolled:    // 没有录入 Touch ID
                    message = NSLocalizedString("未开启 Touch ID", comment: "未开启 Touch ID")
                case kLAErrorBiometryNotEnrolled:   // 没有录入 Touch ID / Face ID 数据
                    message = NSLocalizedString("未开启 Face ID", comment: "未开启 Face ID")
                case kLAErrorTouchIDNotAvailable, kLAErrorBiometryNotAvailable, kLAErrorWatchNotAvailable: // 设备不支持 Touch ID / Face ID / Watch
                    message = NSLocalizedString("设备不支持生物认证", comment: "设备不支持生物认证")
                case kLAErrorNotInteractive:    // 身份验证失败，因为它需要显示 UI，而使用 interactionnotal 属性禁止显示 UI
                    message = NSLocalizedString("设备不支持生物认证", comment: "设备不支持生物认证")
                case kLAErrorTouchIDLockout,    // Touch ID 被锁定 (错误次数过多)
                     kLAErrorBiometryLockout:   // Face ID 被锁定 (错误次数过多)
                    block(context, nil)
                    return context.biometryType
                default: break
                }
            }
            block(nil, message)
            return context.biometryType
        }
    }
    
    /// 进行生物认证
    /// - Parameters:
    ///   - context: LAContext
    ///   - block: 认证结果回调
    static private func authentication(context: LAContext, block: @escaping (Bool) -> Void) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: NSLocalizedString("提示信息", comment: "提示信息")) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    block(true)
                }
            } else {
                guard let aerror = error as NSError? else { return }
                switch Int32(aerror.code) {
                case kLAErrorSystemCancel,  // 切换到其他APP，系统取消验证Touch ID
                     kLAErrorUserCancel, // 用户取消验证Touch ID
                     kLAErrorAppCancel: // 身份验证被应用程序取消(例如，在身份验证过程中调用invalidate)
                    break
                case kLAErrorUserFallback: // 用户选择输入密码，切换主线程处理
                    break
                case kLAErrorAuthenticationFailed: // 身份验证未成功, 未能提供有效凭据
                    break
                case kLAErrorTouchIDLockout,    // Touch ID 被锁定 (错误次数过多)
                     kLAErrorBiometryLockout:   // Face ID 被锁定 (错误次数过多)
                    /// 调用设备密码认证, 解除锁定
                    deviceAuthentication(context: context)
                case kLAErrorInvalidContext:    // 实例化的 LAContext 对象失效
                    break
                default: break
                }
                block(false)
            }
        }
    }
    
    /// 调起设备解锁 (解除生物认证失败过多造成的锁定)
    static private func deviceAuthentication(context: LAContext) {
        DispatchQueue.main.async {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason:  NSLocalizedString("请输入密码解除锁定", comment: "请输入密码解除锁定")) { (success, error) in
                
            }
        }
    }
    
    static func biometricsTypeName() -> String {
        switch LAContext().biometryType {
        case .faceID:
            return "FaceID"
        case .touchID:
            return "TouchID"
        default:
            return "none"
        }
    }
}
