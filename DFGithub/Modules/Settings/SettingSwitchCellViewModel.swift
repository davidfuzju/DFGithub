//
//  SettingSwitchCellViewModel.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import Foundation
import RxSwift
import RxCocoa

class SettingSwitchCellViewModel: DefaultTableViewCellViewModel {

    let isEnabled = BehaviorRelay<Bool>(value: false)

    let switchChanged = PublishSubject<Bool>()

    init(with title: String, detail: String?, image: UIImage?, hidesDisclosure: Bool, isEnabled: Bool) {
        super.init()
        self.title.accept(title)
        self.secondDetail.accept(detail)
        self.image.accept(image)
        self.hidesDisclosure.accept(hidesDisclosure)
        self.isEnabled.accept(isEnabled)
    }
}
