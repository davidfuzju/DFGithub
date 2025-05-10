//
//  LoginViewModel.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxCocoa
import RxSwift
import RxSwiftExt
import SafariServices
import AuthenticationServices

private let loginURL = URL(string: "http://github.com/login/oauth/authorize?client_id=\(Keys.github.appId)&scope=\(Configs.App.githubScope)")!

class LoginViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let oAuthLoginTrigger: Driver<Void>
    }
    
    struct Output {}
    
    let code = PublishSubject<String>()
    
    var tokenSaved = PublishSubject<Void>()
    
    private var authSession: ASWebAuthenticationSession?
    
    func transform(input: Input) -> Output {
        input.oAuthLoginTrigger
            .drive(onNext: { [weak self] () in
                guard let self = self else { return }
                self.authSession = ASWebAuthenticationSession(url: loginURL, callbackURLScheme: appScheme, completionHandler: { callbackUrl, error in
                    if let error = error {
                        logError(error.localizedDescription)
                    }
                    if let codeValue = callbackUrl?.queryParameters?["code"] {
                        self.code.onNext(codeValue)
                    }
                })
                if #available(iOS 13.0, *) {
                    self.authSession?.presentationContextProvider = self
                }
                self.authSession?.start()
            })
            .disposed(by: rx.disposeBag)
        
        let tokenRequest = code
            .flatMapLatest { (code) -> Observable<RxSwift.Event<Token>> in
                let clientId = Keys.github.appId
                let clientSecret = Keys.github.apiKey
                return self.provider.createAccessToken(clientId: clientId, clientSecret: clientSecret, code: code, redirectUri: nil, state: nil)
                    .trackActivity(self.loading)
                    .materialize()
            }
            .share()
        
        tokenRequest.elements()
            .subscribe(onNext: { [weak self] (token) in
                guard let self = self else { return }
                AuthManager.setToken(token: token)
                self.tokenSaved.onNext(())
            })
            .disposed(by: rx.disposeBag)
        
        tokenRequest.errors().bind(to: serverError).disposed(by: rx.disposeBag)
        
        let profileRequest = tokenSaved
            .flatMapLatest {
                return self.provider.profile()
                    .trackActivity(self.loading)
                    .materialize()
            }
            .share()
        
        profileRequest.elements()
            .subscribe(onNext: { (user) in
                user.save()
                AuthManager.tokenValidated()
                Application.shared.presentInitialScreen(in: Application.shared.window)
            })
            .disposed(by: rx.disposeBag)
        
        profileRequest.errors().bind(to: serverError).disposed(by: rx.disposeBag)
        
        serverError
            .subscribe(onNext: { (error) in
                AuthManager.removeToken()
            })
            .disposed(by: rx.disposeBag)
        
        return Output()
    }
}

extension LoginViewModel: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .last!
    }
}
