//
//  SettingsViewController.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SettingsViewController: TableViewController {
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged
            .subscribe(onNext: { [weak self] () in
                guard let self = self else { return }
                self.navigationTitle = R.string.localizable.settingsNavigationTitle.key.localized()
            })
            .disposed(by: rx.disposeBag)
        
        tableView.register(cellWithClass: SettingCell.self)
        tableView.register(cellWithClass: SettingSwitchCell.self)
        tableView.register(cellWithClass: UserCell.self)
        tableView.register(cellWithClass: RepositoryCell.self)
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? SettingsViewModel else { return }
        
        let refresh = Observable.of(rx.viewWillAppear.mapToVoid(), languageChanged.asObservable()).merge()
        let input = SettingsViewModel.Input(trigger: refresh,
                                            selection: tableView.rx.modelSelected(SettingsSectionItem.self).asDriver())
        let output = viewModel.transform(input: input)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SettingsSection>(
            configureCell: { dataSource, tableView, indexPath, item in
                switch item {
                case .profileItem(let viewModel):
                    let cell = tableView.dequeueReusableCell(withClass: UserCell.self, for: indexPath)
                    cell.bind(to: viewModel)
                    return cell
                case .nightModeItem(let viewModel),
                        .biometryItem(let viewModel):
                    let cell = tableView.dequeueReusableCell(withClass: SettingSwitchCell.self, for: indexPath)
                    cell.bind(to: viewModel)
                    return cell
                case .languageItem(let viewModel),
                        .logoutItem(let viewModel):
                    let cell = tableView.dequeueReusableCell(withClass: SettingCell.self, for: indexPath)
                    cell.bind(to: viewModel)
                    return cell
                }
            },
            titleForHeaderInSection: { dataSource, index in
                let section = dataSource[index]
                return section.title
            })
        
        output.items.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
        
        output.selectedEvent.drive(onNext: { [weak self] (item) in
            guard let self = self else { return }
            switch item {
            case .profileItem:
                if let viewModel = viewModel.viewModel(for: item) as? UserViewModel {
                    self.navigator.show(segue: .userDetails(viewModel: viewModel), sender: self)
                }
            case .logoutItem:
                self.deselectSelectedRow()
                self.logoutAction()
            case .nightModeItem, .biometryItem:
                self.deselectSelectedRow()
            case .languageItem:
                if let viewModel = viewModel.viewModel(for: item) as? LanguageViewModel {
                    self.navigator.show(segue: .language(viewModel: viewModel), sender: self)
                }
            }
        }).disposed(by: rx.disposeBag)
    }
    
    func logoutAction() {
        var name = ""
        if let user = User.currentUser() {
            name = user.name ?? user.login ?? ""
        }
        
        let alertController = UIAlertController(title: name,
                                                message: R.string.localizable.settingsLogoutAlertMessage.key.localized(),
                                                preferredStyle: UIAlertController.Style.alert)
        let logoutAction = UIAlertAction(title: R.string.localizable.settingsLogoutAlertConfirmButtonTitle.key.localized(),
                                         style: .destructive) { [weak self] (result: UIAlertAction) in
            self?.logout()
        }
        
        let cancelAction = UIAlertAction(title: R.string.localizable.commonCancel.key.localized(),
                                         style: .default) { (result: UIAlertAction) in
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logout() {
        User.removeCurrentUser()
        AuthManager.removeToken()
        Application.shared.presentInitialScreen(in: Application.shared.window)
    }
}
