//
//  MainTabBarViewModel.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxCocoa
import RxSwift

class MainTabBarViewModel: ViewModel, ViewModelType {

    struct Input { }

    struct Output {
        let tabBarItems: Driver<[HomeTabBarItem]>
    }

    let authorized: Bool

    init(authorized: Bool, provider: DFGithubAPI) {
        self.authorized = authorized
        super.init(provider: provider)
    }

    func transform(input: Input) -> Output {

        let tabBarItems = Observable.just(authorized).map { (authorized) -> [HomeTabBarItem] in
            if authorized {
                return [.home, .settings]
            } else {
                return [.home, .login, .settings]
            }
        }.asDriver(onErrorJustReturn: [])

        return Output(tabBarItems: tabBarItems)
    }

    func viewModel(for tabBarItem: HomeTabBarItem) -> ViewModel {
        switch tabBarItem {
        case .home:
            let viewModel = HomeViewModel(provider: provider)
            return viewModel
        case .settings:
            let viewModel = SettingsViewModel(provider: provider)
            return viewModel
        case .login:
            let viewModel = LoginViewModel(provider: provider)
            return viewModel
        }
    }
}
