//
//  HomeSections.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxDataSources

enum SearchSection {
    case repositories(title: String, items: [SearchSectionItem])
    case users(title: String, items: [SearchSectionItem])
}

enum SearchSectionItem {
    case trendingRepositoriesItem(cellViewModel: TrendingRepositoryCellViewModel)
    case trendingUsersItem(cellViewModel: TrendingUserCellViewModel)
    case repositoriesItem(cellViewModel: RepositoryCellViewModel)
    case usersItem(cellViewModel: UserCellViewModel)
}

extension SearchSection: SectionModelType {
    typealias Item = SearchSectionItem

    var title: String {
        switch self {
        case .repositories(let title, _): return title
        case .users(let title, _): return title
        }
    }

    var items: [SearchSectionItem] {
        switch  self {
        case .repositories(_, let items): return items.map {$0}
        case .users(_, let items): return items.map {$0}
        }
    }

    init(original: SearchSection, items: [Item]) {
        switch original {
        case .repositories(let title, let items): self = .repositories(title: title, items: items)
        case .users(let title, let items): self = .users(title: title, items: items)
        }
    }
}
