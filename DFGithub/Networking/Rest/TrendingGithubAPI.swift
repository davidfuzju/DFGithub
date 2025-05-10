//
//  TrendingGithubAPI.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import Moya

enum TrendingGithubAPI {
    case trendingRepositories(language: String, since: String)
    case trendingDevelopers(language: String, since: String)
}

extension TrendingGithubAPI: TargetType, ProductAPIType {

    var baseURL: URL {
        return Configs.Network.trendingGithubBaseUrl.url!
    }

    var path: String {
        switch self {
        case .trendingRepositories: return "/repositories"
        case .trendingDevelopers: return "/developers"
        }
    }

    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }

    var headers: [String: String]? {
        return nil
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .trendingRepositories(let language, let since),
             .trendingDevelopers(let language, let since):
            params["language"] = language
            params["since"] = since
        }
        return params
    }

    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    public var task: Task {
        if let parameters = parameters {
            return .requestParameters(parameters: parameters, encoding: parameterEncoding)
        }
        return .requestPlain
    }

    var addXAuth: Bool {
        switch self {
        default: return false
        }
    }
}
