//
//  SecurityGuardViewController.swift
//  DFGithub
//
//  Created by David FU on 2025/5/11.
//

import UIKit

import RxSwift
import RxCocoa

class SecurityGuardViewController: ViewController {
    
    lazy var label: Label = {
        let view = Label()
        view.text = R.string.localizable.biometryTitle.key.localized()
        view.font = view.font.withSize(20)
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()
    
    lazy var retryButton: Button = {
        let view = Button()
        view.setTitleForAllStates(R.string.localizable.biometryButtonTitle.key.localized())
        return view
    }()
    
    lazy var blurBackground: VisualEffectView = {
        let view = VisualEffectView()
        view.blurRadius = 40
        view.colorTint = .clear
        return view
    }()
    
    override func makeUI() {
        super.makeUI()
        view.backgroundColor = .clear
        
        view.addSubview(blurBackground)
        blurBackground.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.removeFromSuperview()
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(retryButton)
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(self.inset * 2)
            make.height.equalTo(200)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
        }
    }

    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? SecurityGuardViewModel else { return }
        
        /// 初次进入要故意延迟一下时间，这样才能让 SecurtyGuard 有足够时间完成动画
        let input = SecurityGuardViewModel.Input(trigger: Observable.just(()).delay(.milliseconds(500), scheduler: MainScheduler.instance),
                                                   authenticateButtonClick: retryButton.rx.tap.throttleForUI().mapToVoid())
        let output = viewModel.transform(input: input)
        
        output.didAuthenticate
            .drive(onNext: { [weak self] e in
                guard let self = self else { return }
                if e == true {
                    // success
                    self.entryPresenting?.dismiss(.displayed, with: nil)
                } else {
                    // failed, no nothing
                }
            })
            .disposed(by: rx.disposeBag)
    }
}
