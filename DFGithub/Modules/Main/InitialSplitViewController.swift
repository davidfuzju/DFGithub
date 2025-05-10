//
//  InitialSplitViewController.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit

class InitialSplitViewController: ViewController {

    override func makeUI() {
        super.makeUI()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }

        emptyDataSetTitle = R.string.localizable.initialNoResults.key.localized()
        //tableView.headRefreshControl = nil
        //tableView.footRefreshControl = nil
    }
}
