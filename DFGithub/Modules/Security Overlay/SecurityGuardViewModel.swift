//
//  SecurityGuardViewModel.swift
//  DFGithub
//
//  Created by David FU on 2025/5/11.
//

import Foundation
import RxSwift
import RxCocoa

class SecurityGuardViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let trigger: Observable<Void>
        let authenticateButtonClick: Observable<Void>
    }
    
    struct Output {
        let didAuthenticate: Driver<Bool>
    }
    
    override init(provider: DFGithubAPI) {
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        
        let didAuthenticate = Observable.of(input.trigger, input.authenticateButtonClick).merge()
            .flatMap { _ in
                return AuthManager.shared.authenticate(reason: R.string.localizable.biometryAuthenticateReason.key.localized()).asObservable()
                    .trackActivity(self.loading)
                    .trackError(self.error)
                    .catchAndReturn(false)
            }
            .asDriverOnErrorJustComplete()
        
        return Output(didAuthenticate: didAuthenticate)
    }
}
