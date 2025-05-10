//
//  Switch.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit

class Switch: UISwitch {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        self.theme.tintColor = themeService.attribute { $0.secondary }
        self.theme.onTintColor = themeService.attribute { $0.secondary }
    }
}
