//
//  LogManger.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxSwift

public func logDebug(_ message: @autoclosure () -> String) {}

public func logError(_ message: @autoclosure () -> String) {}

public func logInfo(_ message: @autoclosure () -> String) {}

public func logVerbose(_ message: @autoclosure () -> String) {}

public func logWarn(_ message: @autoclosure () -> String) { }

public func logResourcesCount() {
    #if DEBUG
    logDebug("RxSwift resources count: \(RxSwift.Resources.total)")
    #endif
}
