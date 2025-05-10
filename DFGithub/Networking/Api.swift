//
//  Api.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxSwift
import RxCocoa

protocol DFGithubAPI {
    // MARK: - Authentication is optional
    func createAccessToken(clientId: String, clientSecret: String, code: String, redirectUri: String?, state: String?) -> Single<Token>
    func searchRepositories(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<RepositorySearch>
    func searchUsers(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<UserSearch>
    func user(owner: String) -> Single<User>
    func organization(owner: String) -> Single<User>

    // MARK: - Authentication is required
    func profile() -> Single<User>
    func checkFollowing(username: String) -> Single<Void>

    // MARK: - Trending
    func trendingRepositories(language: String, since: String) -> Single<[TrendingRepository]>
    func trendingDevelopers(language: String, since: String) -> Single<[TrendingUser]>
}
