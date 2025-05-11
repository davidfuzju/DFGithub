//
//  AuthManager.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import KeychainAccess
import ObjectMapper
import RxSwift
import RxCocoa
import LocalAuthentication

let loggedIn = BehaviorRelay<Bool>(value: false)

class AuthManager: NSObject {
    
    /// The default singleton instance.
    static let shared = AuthManager()
    
    fileprivate let tokenKey = "TokenKey"
    fileprivate let keychain = Keychain(service: Configs.App.bundleIdentifier)
    
    let tokenChanged = PublishSubject<Token?>()
    
    /// 生物识别
    private let context = LAContext()
    private let authSubject = PublishSubject<Bool>()
    let biometryEnabled = BehaviorRelay(value: UserDefaults.standard.bool(forKey: Configs.UserDefaultsKeys.biometryEnabled))
    
    override init() {
        super.init()
        loggedIn.accept(hasValidToken)
        
        /// 处理生物识别初始状态
        if UserDefaults.standard.object(forKey: Configs.UserDefaultsKeys.biometryEnabled) == nil {
            self.biometryEnabled.accept(true)
        }
        
        /// 生物识别启动关闭后确保本地化
        self.biometryEnabled
            .skip(1)
            .subscribe(onNext: { (enabled) in
                UserDefaults.standard.set(enabled, forKey: Configs.UserDefaultsKeys.biometryEnabled)
            })
            .disposed(by: rx.disposeBag)
        
        /// 应用在进入前台时开始弹出 Security Overlay 毛玻璃遮罩
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            /// 生物识别成功一次后，识别状态会存在大概 5s ~ 1min 左右，这里做一个时间窗口的过滤，避免 SecurityGaurd 多次弹出
            /// TODO: davidfu 因为是 demo，所以这里做简单处理
            .throttle(.seconds(10), latest: false, scheduler: MainScheduler.instance)
            /// 设置延迟，以便首页动画展开
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .withUnretained(self)
            /// 全局生物识别是否开启
            .filter { $0.0.biometryEnabled.value == true }
            /// 是否有登录态
            .filter { $0.0.hasValidToken }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                let viewModel = SecurityGuardViewModel(provider: Application.shared.provider!)
                Navigator.default.show(segue: .securityGuard(viewModel: viewModel), sender: nil, transition: .entryWith(attributes: .presentOverFullScreen))
            })
            .disposed(by: rx.disposeBag)
    }
    
    var token: Token? {
        get {
            guard let jsonString = keychain[tokenKey] else { return nil }
            return Mapper<Token>().map(JSONString: jsonString)
        }
        set {
            if let token = newValue, let jsonString = token.toJSONString() {
                keychain[tokenKey] = jsonString
            } else {
                keychain[tokenKey] = nil
            }
            tokenChanged.onNext(newValue)
            loggedIn.accept(hasValidToken)
        }
    }
    
    var hasValidToken: Bool {
        return token?.isValid == true
    }
    
    class func setToken(token: Token) {
        AuthManager.shared.token = token
    }
    
    class func removeToken() {
        AuthManager.shared.token = nil
    }
    
    class func tokenValidated() {
        AuthManager.shared.token?.isValid = true
    }
    
    /// 生物识别方法
    /// - Parameter reason: 理由文案
    /// - Returns: Observable
    func authenticate(reason: String) -> Observable<Bool> {
        return Observable.create { observer in
            var error: NSError?
            
            // 检查是否支持生物识别
            guard self.context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                observer.onError(error ?? NSError(domain: "Biometry", code: -1, userInfo: [NSLocalizedDescriptionKey: R.string.localizable.biometryErrorDescripton.key.localized()]))
                return Disposables.create()
            }
            
            // 触发系统生物识别
            self.context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if let authError = authError {
                        observer.onError(authError)
                    } else {
                        observer.onNext(success)
                        observer.onCompleted()
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}
