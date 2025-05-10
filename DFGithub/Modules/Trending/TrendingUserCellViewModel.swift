//
//  TrendingUserCellViewModel.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxSwift
import RxCocoa

class TrendingUserCellViewModel: DefaultTableViewCellViewModel {

    let user: TrendingUser

    init(with user: TrendingUser) {
        self.user = user
        super.init()
        title.accept("\(user.username ?? "") (\(user.name ?? ""))")
        detail.accept(user.repo?.fullname)
        imageUrl.accept(user.avatar)
        badge.accept(R.image.icon_cell_badge_user()?.template)
        badgeColor.accept(UIColor.Material.green900)
    }
}

extension TrendingUserCellViewModel {
    static func == (lhs: TrendingUserCellViewModel, rhs: TrendingUserCellViewModel) -> Bool {
        return lhs.user == rhs.user
    }
}
