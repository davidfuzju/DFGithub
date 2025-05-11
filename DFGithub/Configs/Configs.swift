//
//  Configs.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import CoreGraphics

// All keys are demonstrative and used for the test.
enum Keys {
    case github

    var apiKey: String {
        switch self {
        case .github: return "57823ac56c3e72707243b1574f7bbfb0420133fd"
        }
    }

    var appId: String {
        switch self {
        case .github: return "Ov23liaUcNLhCEhzwaAF"
        }
    }
}

struct Configs {

    struct App {
        static let githubScope = "user+repo+read:org"
        static let bundleIdentifier = "com.davidfu.DFGithub"
    }

    struct Network {
        static let useStaging = false  // set true for tests and generating screenshots with fastlane
        static let loggingEnabled = false
        static let githubBaseUrl = "https://api.github.com"
        static let trendingGithubBaseUrl = "https://github-trending-api.de.a9sapp.eu"
        static let profileSummaryBaseUrl = "https://profile-summary-for-github.com"
    }

    struct BaseDimensions {
        static let inset: CGFloat = 8
        static let tabBarHeight: CGFloat = 58
        static let toolBarHeight: CGFloat = 66
        static let navBarWithStatusBarHeight: CGFloat = 64
        static let cornerRadius: CGFloat = 5
        static let borderWidth: CGFloat = 1
        static let buttonHeight: CGFloat = 40
        static let textFieldHeight: CGFloat = 40
        static let tableRowHeight: CGFloat = 36
        static let segmentedControlHeight: CGFloat = 40
    }

    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        static let Tmp = NSTemporaryDirectory()
    }

    struct UserDefaultsKeys {
        static let biometryEnabled = "BiometryEnabled"
    }
}
