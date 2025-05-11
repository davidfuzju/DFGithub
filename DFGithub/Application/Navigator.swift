//
//  Navigator.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SafariServices
import SwiftEntryKit

protocol Navigatable {
    var navigator: Navigator! { get set }
}

class Navigator {
    static var `default` = Navigator()
    
    // MARK: - segues list, all app scenes
    enum Scene {
        case tabs(viewModel: MainTabBarViewModel)
        case securityGuard(viewModel: SecurityGuardViewModel)
        case userDetails(viewModel: UserViewModel)
        case language(viewModel: LanguageViewModel)
        case web(viewModel: WebViewModel)
        case safariController(URL)
        case safari(URL)
    }
    
    enum Transition {
        enum Scope {
            case global
            case global2(level: UIWindow.Level)
            case local
            case local2(entryPresenting: SwiftEntryPresenting)
        }
        
        case root(in: UIWindow)
        case navigation
        case modal
        case detail
        case entryWith(attributes: EKAttributes, scope: Scope = .global, presentInsideKeyWindow: Bool = false)
    }
    
    // MARK: - get a single VC
    func get(segue: Scene) -> UIViewController? {
        switch segue {
        case .tabs(let viewModel):
            let rootVC = MainTabBarController(viewModel: viewModel, navigator: self)
            let detailVC = InitialSplitViewController(viewModel: nil, navigator: self)
            let detailNavVC = NavigationController(rootViewController: detailVC)
            let splitVC = SplitViewController()
            splitVC.viewControllers = [rootVC, detailNavVC]
            return splitVC
            
        case .securityGuard(let viewModel): return SecurityGuardViewController(viewModel: viewModel, navigator: self)
        case .userDetails(let viewModel): return UserViewController(viewModel: viewModel, navigator: self)
        case .language(let viewModel): return LanguageViewController(viewModel: viewModel, navigator: self)
        case .web(viewModel: let viewModel): return WebViewController(viewModel: viewModel, navigator: self)
        case .safariController(let url):
            let vc = SFSafariViewController(url: url)
            return vc
        case .safari(let url):
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return nil
        }
    }
    
    func pop(sender: UIViewController?, toRoot: Bool = false) {
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        } else {
            sender?.navigationController?.popViewController()
        }
    }
    
    func dismiss(sender: UIViewController?) {
        sender?.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - invoke a single segue
    func show(segue: Scene, sender: UIViewController?, transition: Transition = .navigation) {
        if let target = get(segue: segue) {
            show(target: target, sender: sender, transition: transition)
        }
    }
    
    private func show(target: UIViewController, sender: UIViewController?, transition: Transition) {
        switch transition {
        case .root(in: let window):
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = target
            }, completion: nil)
            return
        default: break
        }
        

        
        if let nav = sender as? UINavigationController {
            // push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }
        
        switch transition {
        case .navigation:
            guard let sender = sender else {
                fatalError("You need to pass in a sender for .navigation or .modal transitions")
            }
            
            if let nav = sender.navigationController {
                nav.pushViewController(target, animated: true)
            }
        case .modal:
            guard let sender = sender else {
                fatalError("You need to pass in a sender for .navigation or .modal transitions")
            }
            
            // present modally
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.present(nav, animated: true, completion: nil)
            }
        case .detail:
            guard let sender = sender else {
                fatalError("You need to pass in a sender for .navigation or .modal transitions")
            }
            
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.showDetailViewController(nav, sender: nil)
            }
        case .entryWith(attributes: let attributes, scope: let scope, presentInsideKeyWindow: let presentInsideKeyWindow):
            
            switch scope {
            case .global:
                // MARK: - ryancao  The keyboard relation does not work the first time when becomeFirstResponder is used in attributes.lifecycleEvents.didAppear
                // https://github.com/huri000/SwiftEntryKit/issues/284
                // UIApplication.shared.display(sender: sender, entry: target, using: attributes)
                SwiftEntryKit.display(sender: sender, entry: target, using: attributes, presentInsideKeyWindow: presentInsideKeyWindow)
            case .global2(level: let level):
                var attrs = attributes
                attrs.windowLevel = EKAttributes.WindowLevel.custom(level: level)
                SwiftEntryKit.display(sender: sender, entry: target, using: attrs, presentInsideKeyWindow: presentInsideKeyWindow)
            case .local:
                sender?.display(sender: sender, entry: target, using: attributes)
            case .local2(entryPresenting: let entryPresenting):
                entryPresenting.display(sender: sender, entry: target, using: attributes)
            }
        default: break
        }
    }
}
