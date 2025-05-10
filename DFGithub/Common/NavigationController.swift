//
//  NavigationController.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit

class NavigationController: UINavigationController {
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: true)
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if viewControllers.count > 0 {
            for (index, viewController) in viewControllers.enumerated() {
                if index > 0 {
                    viewController.hidesBottomBarWhenPushed = true
                }
            }
        }
        super.setViewControllers(viewControllers, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return globalStatusBarStyle.value
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        navigationBar.isTranslucent = false
        navigationBar.backIndicatorImage = R.image.icon_navigation_back()
        navigationBar.backIndicatorTransitionMaskImage = R.image.icon_navigation_back()

        navigationBar.theme.tintColor = themeService.attribute { $0.secondary }
//        navigationBar.theme.barTintColor = themeService.attribute { $0.primaryDark }
        navigationBar.theme.titleTextAttributes = themeService.attribute { [NSAttributedString.Key.foregroundColor: $0.text] }
    }
}
