//
//  Kingfisher+Rx.swift
//  SwiftHub
//
//  Created by Khoren Markosyan on 6/30/18.
//  Copyright © 2018 Khoren Markosyan. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Kingfisher

extension Reactive where Base: UIImageView {
    public var imageURL: Binder<URL?> {
        return self.imageURL()
    }
    
    public func imageURL(withPlaceholder placeholderImage: UIImage? = nil,
                         tintColor: UIColor? = nil,
                         renderingMode: UIImage.RenderingMode = .automatic,
                         transition: ImageTransition = .fade(0.4),
                         forceTransition: Bool = false,
                         loadDiskFileSynchronously: Bool = false) -> Binder<URL?> {
        return Binder(self.base, binding: { imageView, url in
            imageView.df_setImage(with: url,
                                  placeholder: placeholderImage,
                                  tintColor: tintColor,
                                  renderingMode: renderingMode,
                                  transition: transition,
                                  forceTransition: forceTransition,
                                  loadDiskFileSynchronously: loadDiskFileSynchronously,
                                  completion: nil)
        })
    }
}

extension ImageCache: ReactiveCompatible {}

extension Reactive where Base: ImageCache {

    func retrieveCacheSize() -> Observable<Int> {
        return Single.create { single in
            self.base.calculateDiskStorageSize { (result) in
                do {
                    single(.success(Int(try result.get())))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create { }
        }.asObservable()
    }

    public func clearCache() -> Observable<Void> {
        return Single.create { single in
            self.base.clearMemoryCache()
            self.base.clearDiskCache(completion: {
                single(.success(()))
            })
            return Disposables.create { }
        }.asObservable()
    }
}
