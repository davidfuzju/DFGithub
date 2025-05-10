//
//  LoginViewController.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices

enum LoginSegments: Int {
    case oAuth, personal, basic

    var title: String {
        switch self {
        case .oAuth: return R.string.localizable.loginOAuthSegmentTitle.key.localized()
        case .personal: return R.string.localizable.loginPersonalSegmentTitle.key.localized()
        case .basic: return R.string.localizable.loginBasicSegmentTitle.key.localized()
        }
    }
}

class LoginViewController: ViewController {

    // MARK: - OAuth authentication

    lazy var oAuthLoginStackView: StackView = {
        let subviews: [UIView] = [oAuthLogoImageView, titleLabel, detailLabel, oAuthLoginButton]
        let view = StackView(arrangedSubviews: subviews)
        view.spacing = inset * 2
        return view
    }()

    lazy var oAuthLogoImageView: ImageView = {
        let view = ImageView(image: R.image.image_no_result()?.template)
        view.contentMode = .center
        return view
    }()

    lazy var titleLabel: Label = {
        let view = Label()
        view.font = view.font.withSize(22)
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()

    lazy var detailLabel: Label = {
        let view = Label()
        view.font = view.font.withSize(17)
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()

    lazy var oAuthLoginButton: Button = {
        let view = Button()
        view.imageForNormal = R.image.icon_button_github()
        view.centerTextAndImage(spacing: inset)
        return view
    }()

    private lazy var scrollView: ScrollView = {
        let view = ScrollView()
        self.contentView.addSubview(view)
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        return view
    }()

    override func makeUI() {
        super.makeUI()

        languageChanged
            .subscribe(onNext: { [weak self] () in
                guard let self = self else { return }
                // MARK: OAuth
                self.titleLabel.text = R.string.localizable.loginTitleLabelText.key.localized()
                self.detailLabel.text = R.string.localizable.loginDetailLabelText.key.localized()
                self.oAuthLoginButton.titleForNormal = R.string.localizable.loginOAuthloginButtonTitle.key.localized()
            })
            .disposed(by: rx.disposeBag)

        stackView.removeFromSuperview()
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview().inset(self.inset*2)
            make.centerX.equalToSuperview()
        })

        titleLabel.theme.textColor = themeService.attribute { $0.text }

        detailLabel.theme.textColor = themeService.attribute { $0.textGray }
        oAuthLogoImageView.theme.tintColor = themeService.attribute { $0.text }

        stackView.addArrangedSubview(oAuthLoginStackView)
    }

    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? LoginViewModel else { return }

        let input = LoginViewModel.Input(oAuthLoginTrigger: oAuthLoginButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)

        isLoading
            .asDriver()
            .drive(onNext: { [weak self] (isLoading) in
                guard let self = self else { return }
                isLoading ? self.startAnimating() : self.stopAnimating()
            })
            .disposed(by: rx.disposeBag)

        // TODO: davidfu
        //error.subscribe(onNext: { [weak self] (error) in
        //    self?.view.makeToast(error.description, title: error.title, image: R.image.icon_toast_warning())
        //}).disposed(by: rx.disposeBag)
    }
}
