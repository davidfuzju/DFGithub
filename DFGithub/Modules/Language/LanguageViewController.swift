//
//  LanguageViewController.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class LanguageViewController: TableViewController {
    
    lazy var saveButtonItem: BarButtonItem = {
        let view = BarButtonItem(title: "",
                                 style: .plain, target: self, action: nil)
        return view
    }()
    
    override func makeUI() {
        super.makeUI()
        
        languageChanged.subscribe(onNext: { [weak self] () in
            self?.navigationTitle = R.string.localizable.languageNavigationTitle.key.localized()
            self?.saveButtonItem.title = R.string.localizable.commonSave.key.localized()
        }).disposed(by: rx.disposeBag)
        
        navigationItem.rightBarButtonItem = saveButtonItem
        tableView.register(cellWithClass: LanguageCell.self)
        tableView.headRefreshControl = nil
        tableView.footRefreshControl = nil
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? LanguageViewModel else { return }
        
        let refresh = Observable.of(Observable.just(()),
                                    languageChanged.asObservable()).merge()
        let input = LanguageViewModel.Input(trigger: refresh,
                                            saveTrigger: saveButtonItem.rx.tap.asDriver(),
                                            selection: tableView.rx.modelSelected(LanguageCellViewModel.self).asDriver())
        let output = viewModel.transform(input: input)
        
        output.items
            .drive(tableView.rx.items) { tableView, _, viewModel in
                let cell = tableView.dequeueReusableCell(withClass: LanguageCell.self)
                cell.bind(to: viewModel)
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        output.saved
            .drive(onNext: { [weak self] () in
                self?.navigator.dismiss(sender: self)
            })
            .disposed(by: rx.disposeBag)
    }
}
