//
//  SettingsSection.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxDataSources

enum SettingsSection {
    case setting(title: String, items: [SettingsSectionItem])
}

enum SettingsSectionItem {
    // Account
    case profileItem(viewModel: UserCellViewModel)
    case logoutItem(viewModel: SettingCellViewModel)

    // Preferences
    case nightModeItem(viewModel: SettingSwitchCellViewModel)
    case languageItem(viewModel: SettingCellViewModel)
}

extension SettingsSectionItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity {
        switch self {
        case .profileItem(let viewModel): return viewModel.user.login ?? ""
        case .nightModeItem(let viewModel): return viewModel.title.value ?? ""
        case .logoutItem(let viewModel),
                .languageItem(let viewModel):
            return viewModel.title.value ?? ""
        }
    }
}

extension SettingsSectionItem: Equatable {
    static func == (lhs: SettingsSectionItem, rhs: SettingsSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

extension SettingsSection: AnimatableSectionModelType, IdentifiableType {
    typealias Item = SettingsSectionItem

    typealias Identity = String
    var identity: Identity { return title }

    var title: String {
        switch self {
        case .setting(let title, _): return title
        }
    }

    var items: [SettingsSectionItem] {
        switch  self {
        case .setting(_, let items): return items.map {$0}
        }
    }

    init(original: SettingsSection, items: [Item]) {
        switch original {
        case .setting(let title, let items): self = .setting(title: title, items: items)
        }
    }
}
