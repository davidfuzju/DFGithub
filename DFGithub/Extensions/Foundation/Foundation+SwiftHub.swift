//
//  Foundation+SwiftHub.swift
//  SwiftHub
//
//  Created by Sygnoos9 on 11/6/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import Foundation

extension Int {

    func sizeFromKB() -> String {
        return (self*1024).sizeFromByte()
    }

    func sizeFromByte() -> String {
        return ByteCountFormatter.string(fromByteCount: Int64(self), countStyle: .file)
    }

    func kFormatted() -> String {
        let sign = ((self < 0) ? "-" : "" )
        if self < 1000 {
            return "\(sign)\(self)"
        }
        let num = fabs(self.double)
        let exp: Int = Int(log10(num) / 3.0 )
        let units: [String] = ["K", "M", "G", "T", "P", "E"]
        let roundedNum: Double = round(10 * num / pow(1000.0, Double(exp))) / 10
        return "\(sign)\(roundedNum)\(units[exp-1])"
    }
}

extension StaticString {

    func localized() -> String {
        return description.localized()
    }

    func localizedFormat(_ arguments: CVarArg...) -> String {
        return description.localizedFormat(arguments)
    }
}

extension Bundle {
    /// 获取 FRTFoundation 配置信息
    static func getConfigValueFor(key: String) -> String {
        (Bundle.main.infoDictionary?["DFFoundation"] as? [String: String])?[key] ?? ""
    }
}
