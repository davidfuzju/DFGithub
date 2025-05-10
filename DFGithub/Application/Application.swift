//
//  Application.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit

let appScheme = Bundle.getConfigValueFor(key: "DFAppScheme")

final class Application: NSObject {
    static let shared = Application()

    var window: UIWindow?

    var provider: DFGithubAPI?
    let authManager: AuthManager
    let navigator: Navigator

    private override init() {
        authManager = AuthManager.shared
        navigator = Navigator.default
        super.init()
        updateProvider()
    }

    private func updateProvider() {
        let staging = Configs.Network.useStaging
        let githubProvider = staging ? GithubNetworking.stubbingNetworking(): GithubNetworking.defaultNetworking()
        let trendingGithubProvider = staging ? TrendingGithubNetworking.stubbingNetworking(): TrendingGithubNetworking.defaultNetworking()
        let restApi = RestApi(githubProvider: githubProvider, trendingGithubProvider: trendingGithubProvider)
        provider = restApi

        if let token = authManager.token, Configs.Network.useStaging == false { }
    }

    func presentInitialScreen(in window: UIWindow?) {
        updateProvider()
        guard let window = window, let provider = provider else { return }
        self.window = window

        let workItem = DispatchWorkItem {
            if let user = User.currentUser(), let login = user.login { }
            let authorized = self.authManager.token?.isValid ?? false
            let viewModel = MainTabBarViewModel(authorized: authorized, provider: provider)
            self.navigator.show(segue: .tabs(viewModel: viewModel), sender: nil, transition: .root(in: window))
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

}
