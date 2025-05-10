//
//  RestApi.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper
import Moya
import Moya_ObjectMapper
import Alamofire

typealias MoyaError = Moya.MoyaError

enum ApiError: Error {
    case serverError(response: ErrorResponse)

    var title: String {
        switch self {
        case .serverError(let response): return response.message ?? ""
        }
    }

    var description: String {
        switch self {
        case .serverError(let response): return response.detail()
        }
    }
}

class RestApi: DFGithubAPI {

    let githubProvider: GithubNetworking
    let trendingGithubProvider: TrendingGithubNetworking

    init(githubProvider: GithubNetworking, trendingGithubProvider: TrendingGithubNetworking) {
        self.githubProvider = githubProvider
        self.trendingGithubProvider = trendingGithubProvider
    }
}

extension RestApi {

    func downloadString(url: URL) -> Single<String> {
        return Single.create { single in
            DispatchQueue.global().async {
                do {
                    single(.success(try String.init(contentsOf: url)))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create { }
            }
        .observe(on: MainScheduler.instance)
    }

    // MARK: - Authentication is optional

    func createAccessToken(clientId: String, clientSecret: String, code: String, redirectUri: String?, state: String?) -> Single<Token> {
        return Single.create { single in
            var params: Parameters = [:]
            params["client_id"] = clientId
            params["client_secret"] = clientSecret
            params["code"] = code
            params["redirect_uri"] = redirectUri
            params["state"] = state
            AF.request("https://github.com/login/oauth/access_token",
                       method: .post,
                       parameters: params,
                       encoding: URLEncoding.default,
                       headers: ["Accept": "application/json"])
                .responseJSON(completionHandler: { (response) in
                    if let error = response.error {
                        single(.failure(error))
                        return
                    }
                    if let json = response.value as? [String: Any] {
                        if let token = Mapper<Token>().map(JSON: json) {
                            single(.success(token))
                            return
                        }
                    }
                    single(.failure(RxError.unknown))
                })
            return Disposables.create { }
            }
        .observe(on: MainScheduler.instance)
    }
    
    func searchRepositories(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<RepositorySearch> {
        return requestObject(.searchRepositories(query: query, sort: sort, order: order, page: page), type: RepositorySearch.self)
    }
    
    func searchUsers(query: String, sort: String, order: String, page: Int, endCursor: String?) -> Single<UserSearch> {
        return requestObject(.searchUsers(query: query, sort: sort, order: order, page: page), type: UserSearch.self)
    }

    func user(owner: String) -> Single<User> {
        return requestObject(.user(owner: owner), type: User.self)
    }

    func organization(owner: String) -> Single<User> {
        return requestObject(.organization(owner: owner), type: User.self)
    }

    // MARK: - Authentication is required

    func profile() -> Single<User> {
        return requestObject(.profile, type: User.self)
    }
    
    func checkFollowing(username: String) -> Single<Void> {
        return requestWithoutMapping(.checkFollowing(username: username)).map { _ in }
    }

    // MARK: - Trending
    func trendingRepositories(language: String, since: String) -> Single<[TrendingRepository]> {
        return trendingRequestArray(.trendingRepositories(language: language, since: since), type: TrendingRepository.self)
    }

    func trendingDevelopers(language: String, since: String) -> Single<[TrendingUser]> {
        return trendingRequestArray(.trendingDevelopers(language: language, since: since), type: TrendingUser.self)
    }
}

extension RestApi {
    private func request(_ target: GithubAPI) -> Single<Any> {
        return githubProvider.request(target)
            .mapJSON()
            .observe(on: MainScheduler.instance)
            .asSingle()
    }

    private func requestWithoutMapping(_ target: GithubAPI) -> Single<Moya.Response> {
        return githubProvider.request(target)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }

    private func requestObject<T: BaseMappable>(_ target: GithubAPI, type: T.Type) -> Single<T> {
        return githubProvider.request(target)
            .mapObject(T.self)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }

    private func requestArray<T: BaseMappable>(_ target: GithubAPI, type: T.Type) -> Single<[T]> {
        return githubProvider.request(target)
            .mapArray(T.self)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
}

extension RestApi {
    private func trendingRequestObject<T: BaseMappable>(_ target: TrendingGithubAPI, type: T.Type) -> Single<T> {
        return trendingGithubProvider.request(target)
            .mapObject(T.self)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }

    private func trendingRequestArray<T: BaseMappable>(_ target: TrendingGithubAPI, type: T.Type) -> Single<[T]> {
        return trendingGithubProvider.request(target)
            .mapArray(T.self)
            .observe(on: MainScheduler.instance)
            .asSingle()
    }
}
