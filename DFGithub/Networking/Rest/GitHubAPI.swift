//
//  GitHubAPI.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxSwift
import Moya
import Alamofire

protocol ProductAPIType {
    var addXAuth: Bool { get }
}

private let assetDir: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

enum GithubAPI {
    // MARK: - Authentication is optional
    case searchRepositories(query: String, sort: String, order: String, page: Int)
    case searchUsers(query: String, sort: String, order: String, page: Int)
    case user(owner: String)
    case organization(owner: String)

    // MARK: - Authentication is required
    case profile
    case checkFollowing(username: String)
}

extension GithubAPI: TargetType, ProductAPIType {

    var baseURL: URL {
        switch self {
        default:
            return Configs.Network.githubBaseUrl.url!
        }
    }

    var path: String {
        switch self {
        case .searchRepositories: return "/search/repositories"
        case .searchUsers: return "/search/users"
        case .user(let owner): return "/users/\(owner)"
        case .organization(let owner): return "/orgs/\(owner)"
        case .profile: return "/user"
        case .checkFollowing(let username): return "/user/following/\(username)"
        }
    }

    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }

    var headers: [String: String]? {
        if let token = AuthManager.shared.token {
            switch token.type() {
            case .basic(let token):
                return ["Authorization": "Basic \(token)"]
            case .personal(let token):
                return ["Authorization": "token \(token)"]
            case .oAuth(let token):
                return ["Authorization": "token \(token)"]
            case .unauthorized: break
            }
        }
        return nil
    }

    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .searchRepositories(let query, let sort, let order, let page):
            params["q"] = query
            params["sort"] = sort
            params["order"] = order
            params["page"] = page
        case .searchUsers(let query, let sort, let order, let page):
            params["q"] = query
            params["sort"] = sort
            params["order"] = order
            params["page"] = page
        default: break
        }
        return params
    }

    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    public var task: Task {
        switch self {
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }

    var addXAuth: Bool {
        switch self {
        default: return true
        }
    }
}
