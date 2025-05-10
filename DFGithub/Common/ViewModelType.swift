//
//  ViewModelType.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

protocol ViewModelType {
    associatedtype Input
    associatedtype Output

    func transform(input: Input) -> Output
}

class ViewModel: NSObject {

    let provider: DFGithubAPI

    var page = 1

    let loading = ActivityIndicator()
    let headerLoading = ActivityIndicator()
    let footerLoading = ActivityIndicator()

    let error = ErrorTracker()
    let serverError = PublishSubject<Error>()

    init(provider: DFGithubAPI) {
        self.provider = provider
        super.init()
    }

    deinit {
        logDebug("\(type(of: self)): Deinited")
        logResourcesCount()
    }
}
