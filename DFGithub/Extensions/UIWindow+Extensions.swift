//
//  UIWindow.swift
//  DFGithub
//
//  Created by David FU on 2025/5/11.
//

import UIKit

extension UIWindow {
    /// get the keyWindow
    static var keyWindow: UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last { $0.isKind(of: Window.self) }
    }
}
