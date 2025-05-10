//
//  ToolBar.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit

class Toolbar: UIToolbar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        isTranslucent = false

        theme.barStyle = themeService.attribute { $0.barStyle }
        theme.barTintColor = themeService.attribute { $0.primaryDark }
        theme.tintColor = themeService.attribute { $0.secondary }

        snp.makeConstraints { (make) in
            make.height.equalTo(Configs.BaseDimensions.tableRowHeight)
        }
    }
}
