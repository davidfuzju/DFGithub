//
//  LibsManager.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
import IQKeyboardManagerSwift
import IQKeyboardToolbarManager
import Kingfisher
import NSObject_Rx
import RxViewController
import RxOptional
import RxGesture
import SwifterSwift
import KafkaRefresh
import DropDown
import Toast_Swift

typealias DropDownView = DropDown

/// The manager class for configuring all libraries used in app.
class LibsManager: NSObject {

    /// The default singleton instance.
    static let shared = LibsManager()

    private override init() {
        super.init()
    }

    @MainActor func setupLibs() {
        let libsManager = LibsManager.shared
        libsManager.setupTheme()
        libsManager.setupKafkaRefresh()
        libsManager.setupKeyboardManager()
        libsManager.setupDropDown()
        libsManager.setupToast()
        libsManager.setupKingfisher()
    }

    func setupTheme() {
        UIApplication.shared.theme.statusBarStyle = themeService.attribute { $0.statusBarStyle }
    }

    func setupDropDown() {
        themeService.typeStream.subscribe(onNext: { (themeType) in
            let theme = themeType.associatedObject
            DropDown.appearance().backgroundColor = theme.primary
            DropDown.appearance().selectionBackgroundColor = theme.primaryDark
            DropDown.appearance().textColor = theme.text
            DropDown.appearance().selectedTextColor = theme.text
            DropDown.appearance().separatorColor = theme.separator
        }).disposed(by: rx.disposeBag)
    }

    func setupToast() {
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.position = .top
        var style = ToastStyle()
        style.backgroundColor = UIColor.Material.red
        style.messageColor = UIColor.Material.white
        style.imageSize = CGSize(width: 20, height: 20)
        ToastManager.shared.style = style
    }

    func setupKafkaRefresh() {
        if let defaults = KafkaRefreshDefaults.standard() {
            defaults.headDefaultStyle = .replicatorAllen
            defaults.footDefaultStyle = .replicatorDot
            defaults.theme.themeColor = themeService.attribute { $0.secondary }
        }
    }

    @MainActor func setupKeyboardManager() {
        IQKeyboardManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.isEnabled = true
        IQKeyboardToolbarManager.shared.toolbarConfiguration.useTextInputViewTintColor = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }

    func setupKingfisher() {
        ImageCache.default.diskStorage.config.sizeLimit = UInt(1024 * 1024 * 1024)
        ImageCache.default.diskStorage.config.expiration = .days(30)

        ImageCache.default.memoryStorage.config.countLimit = 150
        ImageCache.default.memoryStorage.config.expiration = .seconds(600)

        ImageDownloader.default.downloadTimeout = 15.0 // 15 sec
    }
}
