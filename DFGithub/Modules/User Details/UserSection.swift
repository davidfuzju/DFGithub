//
//  UserSection.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxDataSources

enum UserSection {
    case user(title: String, items: [UserSectionItem])
}

enum UserSectionItem {
    case repositoriesCount(viewModel: UserDetailCellViewModel)
    case followerCount(viewModel: UserDetailCellViewModel)
    case followingCount(viewModel: UserDetailCellViewModel)
    case createdItem(viewModel: UserDetailCellViewModel)
    case updatedItem(viewModel: UserDetailCellViewModel)
    case starsItem(viewModel: UserDetailCellViewModel)
    case watchingItem(viewModel: UserDetailCellViewModel)
    case companyItem(viewModel: UserDetailCellViewModel)
    case blogItem(viewModel: UserDetailCellViewModel)
    case profileSummaryItem(viewModel: UserDetailCellViewModel)
}

extension UserSection: SectionModelType {
    typealias Item = UserSectionItem

    var title: String {
        switch self {
        case .user(let title, _): return title
        }
    }

    var items: [UserSectionItem] {
        switch  self {
        case .user(_, let items): return items.map {$0}
        }
    }

    init(original: UserSection, items: [Item]) {
        switch original {
        case .user(let title, let items): self = .user(title: title, items: items)
        }
    }
}
