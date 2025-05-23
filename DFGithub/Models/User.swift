//
//  User.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import ObjectMapper
import KeychainAccess

private let userKey = "CurrentUserKey"
private let keychain = Keychain(service: Configs.App.bundleIdentifier)

enum UserType: String {
    case user = "User"
    case organization = "Organization"
}

/// User model
struct User: Mappable {
    
    var avatarUrl: String?  // A URL pointing to the user's public avatar.
    var blog: String?  // A URL pointing to the user's public website/blog.
    var company: String?  // The user's public profile company.
    var contributions: Int?
    var createdAt: Date?  // Identifies the date and time when the object was created.
    var email: String?  // The user's publicly visible profile email.
    var followers: Int?  // Identifies the total count of followers.
    var following: Int? // Identifies the total count of following.
    var htmlUrl: String?  // The HTTP URL for this user
    var location: String?  // The user's public profile location.
    var login: String?  // The username used to login.
    var name: String?  // The user's public profile name.
    var type: UserType = .user
    var updatedAt: Date?  // Identifies the date and time when the object was last updated.
    var starredRepositoriesCount: Int?  // Identifies the total count of repositories the user has starred.
    var repositoriesCount: Int?  // Identifies the total count of repositories that the user owns.
    var issuesCount: Int?  // Identifies the total count of issues associated with this user
    var watchingCount: Int?  // Identifies the total count of repositories the given user is watching
    var viewerCanFollow: Bool?  // Whether or not the viewer is able to follow the user.
    var viewerIsFollowing: Bool?  // Whether or not this user is followed by the viewer.
    var isViewer: Bool?  // Whether or not this user is the viewing user.
    var pinnedRepositories: [Repository]?  // A list of repositories this user has pinned to their profile
    var organizations: [User]?  // A list of organizations the user belongs to.
    //var contributionCalendar: ContributionCalendar? // A calendar of this user's contributions on GitHub.
    
    // Only for Organization type
    var descriptionField: String?
    
    // Only for User type
    var bio: String?  // The user's public profile bio.
    
    // SenderType
    var senderId: String { return login ?? "" }
    var displayName: String { return login ?? "" }
    
    init?(map: Map) {}
    init() {}
    
    init(login: String?, name: String?, avatarUrl: String?, followers: Int?, viewerCanFollow: Bool?, viewerIsFollowing: Bool?) {
        self.login = login
        self.name = name
        self.avatarUrl = avatarUrl
        self.followers = followers
        self.viewerCanFollow = viewerCanFollow
        self.viewerIsFollowing = viewerIsFollowing
    }
    
    init(user: TrendingUser) {
        self.init(login: user.username, name: user.name, avatarUrl: user.avatar, followers: nil, viewerCanFollow: nil, viewerIsFollowing: nil)
        switch user.type {
        case .user: self.type = .user
        case .organization: self.type = .organization
        }
    }
    
    mutating func mapping(map: Map) {
        avatarUrl <- map["avatar_url"]
        blog <- map["blog"]
        company <- map["company"]
        contributions <- map["contributions"]
        createdAt <- (map["created_at"], ISO8601DateTransform())
        descriptionField <- map["description"]
        email <- map["email"]
        followers <- map["followers"]
        following <- map["following"]
        htmlUrl <- map["html_url"]
        location <- map["location"]
        login <- map["login"]
        name <- map["name"]
        repositoriesCount <- map["public_repos"]
        type <- map["type"]
        updatedAt <- (map["updated_at"], ISO8601DateTransform())
        bio <- map["bio"]
    }
}

extension User {
    func isMine() -> Bool {
        if let isViewer = isViewer {
            return isViewer
        }
        return self == User.currentUser()
    }
    
    func save() {
        if let json = self.toJSONString() {
            keychain[userKey] = json
        } else {
            logError("User can't be saved")
        }
    }
    
    static func currentUser() -> User? {
        if let json = keychain[userKey], let user = User(JSONString: json) {
            return user
        }
        return nil
    }
    
    static func removeCurrentUser() {
        keychain[userKey] = nil
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.login == rhs.login
    }
}

/// UserSearch model
struct UserSearch: Mappable {
    
    var items: [User] = []
    var totalCount: Int = 0
    var incompleteResults: Bool = false
    var hasNextPage: Bool = false
    var endCursor: String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        items <- map["items"]
        totalCount <- map["total_count"]
        incompleteResults <- map["incomplete_results"]
        hasNextPage = items.isNotEmpty
    }
}

enum TrendingUserType: String {
    case user
    case organization
}


//{
//    "username": "ayangweb",
//    "repo": {
//        "name": "BongoCat",
//        "url": "https:\/\/github.com\/ayangweb\/BongoCat",
//        "description": "BongoCat 是一个可爱的互动桌面宠物应用，让你的桌面充满乐趣！"
//    },
//    "name": "ayangweb",
//    "url": "https:\/\/github.com\/ayangweb",
//    "avatar": "https:\/\/avatars.githubusercontent.com\/u\/75017711"
//}

/// TrendingUser model
struct TrendingUser: Mappable {
    
    var username: String?
    var name: String?
    var url: String?
    var avatar: String?
    var repo: TrendingRepository?
    var type: TrendingUserType = .user
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        username <- map["username"]
        name <- map["name"]
        url <- map["url"]
        avatar <- map["avatar"]
        repo <- map["repo"]
        type <- map["type"]
        repo?.author = username
    }
}

extension TrendingUser: Equatable {
    static func == (lhs: TrendingUser, rhs: TrendingUser) -> Bool {
        return lhs.username == rhs.username
    }
}
