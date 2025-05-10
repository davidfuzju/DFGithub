//
//  SettingsViewModel.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

class SettingsViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let trigger: Observable<Void>
        let selection: Driver<SettingsSectionItem>
    }
    
    struct Output {
        let items: BehaviorRelay<[SettingsSection]>
        let selectedEvent: Driver<SettingsSectionItem>
    }
    
    let currentUser: User?
    
    let nightModeEnabled: BehaviorRelay<Bool>
    
    var cellDisposeBag = DisposeBag()
    
    override init(provider: DFGithubAPI) {
        currentUser = User.currentUser()
        nightModeEnabled = BehaviorRelay(value: ThemeType.currentTheme().isDark)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        
        let elements = BehaviorRelay<[SettingsSection]>(value: [])
        
        let refresh = Observable.of(input.trigger, nightModeEnabled.mapToVoid()).merge()
        
        refresh.map { [weak self] _  -> [SettingsSection] in
            guard let self = self else { return [] }
            self.cellDisposeBag = DisposeBag()
            var items: [SettingsSection] = []
            
            if loggedIn.value {
                var accountItems: [SettingsSectionItem] = []
                if let user = self.currentUser {
                    let profileCellViewModel = UserCellViewModel(with: user)
                    accountItems.append(SettingsSectionItem.profileItem(viewModel: profileCellViewModel))
                }
                
                let logoutCellViewModel = SettingCellViewModel(with: R.string.localizable.settingsLogOutTitle.key.localized(), detail: nil,
                                                               image: R.image.icon_cell_logout()?.template, hidesDisclosure: true)
                accountItems.append(SettingsSectionItem.logoutItem(viewModel: logoutCellViewModel))
                
                items.append(SettingsSection.setting(title: R.string.localizable.settingsAccountSectionTitle.key.localized(), items: accountItems))
            }
            
            let nightModeEnabled = self.nightModeEnabled.value
            let nightModeCellViewModel = SettingSwitchCellViewModel(with: R.string.localizable.settingsNightModeTitle.key.localized(),
                                                                    detail: nil,
                                                                    image: R.image.icon_cell_night_mode()?.template,
                                                                    hidesDisclosure: true,
                                                                    isEnabled: nightModeEnabled)
            nightModeCellViewModel.switchChanged.skip(1).bind(to: self.nightModeEnabled).disposed(by: self.cellDisposeBag)
            
            let languageCellViewModel = SettingCellViewModel(with: R.string.localizable.settingsLanguageTitle.key.localized(),
                                                             detail: nil,
                                                             image: R.image.icon_cell_language()?.template,
                                                             hidesDisclosure: false)
            
            items += [
                SettingsSection.setting(title: R.string.localizable.settingsPreferencesSectionTitle.key.localized(), items: [
                    SettingsSectionItem.nightModeItem(viewModel: nightModeCellViewModel),
                    SettingsSectionItem.languageItem(viewModel: languageCellViewModel)
                ]),
            ]
            
            return items
        }
        .bind(to: elements)
        .disposed(by: rx.disposeBag)
        
        let selectedEvent = input.selection
        
        nightModeEnabled
            .subscribe(onNext: { (isEnabled) in
                var theme = ThemeType.currentTheme()
                if theme.isDark != isEnabled {
                    theme = theme.toggled()
                }
                themeService.switch(theme)
            })
            .disposed(by: rx.disposeBag)
        
        nightModeEnabled
            .skip(1)
            .subscribe(onNext: { (isEnabled) in
            })
            .disposed(by: rx.disposeBag)
        
        return Output(items: elements,
                      selectedEvent: selectedEvent)
    }
    
    func viewModel(for item: SettingsSectionItem) -> ViewModel? {
        switch item {
        case .profileItem:
            let viewModel = UserViewModel(user: currentUser ?? User(), provider: provider)
            return viewModel
        case .languageItem:
            let viewModel = LanguageViewModel(provider: self.provider)
            return viewModel
        default:
            return nil
        }
    }
    
}
