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

protocol Navigatable {
    var navigator: Navigator! { get set }
}

class Navigator {
    static var `default` = Navigator()
    
    // MARK: - segues list, all app scenes
    enum Scene {
        case tabs(viewModel: MainTabBarViewModel)
        case userDetails(viewModel: UserViewModel)
        case language(viewModel: LanguageViewModel)
        case web(viewModel: WebViewModel)
        case safariController(URL)
        case safari(URL)
    }
    
    enum Transition {
        case root(in: UIWindow)
        case navigation
        case modal
        case detail
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
        
        guard let sender = sender else {
            fatalError("You need to pass in a sender for .navigation or .modal transitions")
        }
        
        if let nav = sender as? UINavigationController {
            // push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }
        
        switch transition {
        case .navigation:
            if let nav = sender.navigationController {
                nav.pushViewController(target, animated: true)
            }
        case .modal:
            // present modally
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.present(nav, animated: true, completion: nil)
            }
        case .detail:
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.showDetailViewController(nav, sender: nil)
            }
        default: break
        }
    }
}
