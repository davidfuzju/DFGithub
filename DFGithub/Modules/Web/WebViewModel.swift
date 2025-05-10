//
//  WebViewModel.swift
//  FOURTRY
//
//  Created by David FU on 2023/12/25.
//

import Foundation
import RxSwift
import RxCocoa

class WebViewModel: ViewModel, ViewModelType {
    
    struct Input {
        let rightBarButtonClick: Observable<Void>
        let goBackBarButtonClick: Observable<Void>
        let goFowardBarButtonClick: Observable<Void>
        let stopReloadBarButtonClick: Observable<Void>
    }

    struct Output {
        let didURLShouldLoad: Driver<URL>
        let didRightBarButtonClick: Driver<URL>
        let didGoBackBarButtonClick: Driver<URL>
        let didGoFowardBarButtonClick: Driver<URL>
        let didStopReloadBarButtonClick: Driver<URL>
    }
    
    let url: BehaviorRelay<URL>
    
    init(with url: URL, provider: DFGithubAPI) {
        self.url = BehaviorRelay<URL>(value: url)
        super.init(provider: provider)
    }
    
    func transform(input: Input) -> Output {
        let didURLShouldLoad = self.url.asDriver()
        
        let didRightBarButtonClick = input.rightBarButtonClick
            .withLatestFrom(url)
            .asDriverOnErrorJustComplete()
        
        let didGoBackBarButtonClick = input.goBackBarButtonClick
            .withLatestFrom(url)
            .asDriverOnErrorJustComplete()
        
        let didGoFowardBarButtonClick = input.goFowardBarButtonClick
            .withLatestFrom(url)
            .asDriverOnErrorJustComplete()
        
        let didStopReloadBarButtonClick = input.stopReloadBarButtonClick
            .withLatestFrom(url)
            .asDriverOnErrorJustComplete()
        
        return Output(
            didURLShouldLoad: didURLShouldLoad,
            didRightBarButtonClick: didRightBarButtonClick,
            didGoBackBarButtonClick: didGoBackBarButtonClick,
            didGoFowardBarButtonClick: didGoFowardBarButtonClick,
            didStopReloadBarButtonClick: didStopReloadBarButtonClick
        )
    }
}
