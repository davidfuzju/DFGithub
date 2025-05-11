//
//  ImageView.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit

import Kingfisher

class ImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        makeUI()
    }
    
    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        makeUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    func makeUI() {
        tintColor = .primary()
        layer.masksToBounds = true
        
        updateUI()
    }
    
    func updateUI() {
        setNeedsDisplay()
    }
}

extension UIImageView {
    /// 统一网络图片加载方法
    /// - Parameters:
    ///   - url: 网络图片地址
    ///   - placeholder: 默认的 placeholder 图片
    ///   - completion: 完成回调
    public func df_setImage(with url: URL?,
                            placeholder: UIImage? = nil,
                            tintColor: UIColor? = nil,
                            renderingMode: UIImage.RenderingMode = .automatic,
                            transition: ImageTransition = .fade(0.4),
                            forceTransition: Bool = false,
                            loadDiskFileSynchronously: Bool = false,
                            completion: ((UIImage?, Error?) -> Void)? = nil) {
        
        let progressive = ImageProgressive(
            isBlur: true,
            isFastestScan: true,
            scanInterval: 0.2
        )
        
        let builder = KF.url(url)
            .progressiveJPEG(progressive)
            .placeholder(placeholder)
            .scaleFactor(UIScreen.main.scale)
            .imageModifier(RenderingModeImageModifier(renderingMode: renderingMode))
            .transition(transition)
            .forceTransition(forceTransition)
        
        if let tintColor = tintColor {
            _ = builder.tint(color: tintColor)
        }
        
        if loadDiskFileSynchronously {
            // https://github.com/onevcat/Kingfisher/wiki/Cheat-Sheet#loading-disk-file-synchronously
            _ = builder.loadDiskFileSynchronously()
        }
        
        _ = builder
            .onSuccess { result in
                if completion != nil {
                    completion!(result.image, nil)
                }
            }
            .onFailure { error in
                if completion != nil {
                    completion!(nil, error)
                }
            }
        
        builder.set(to: self)
    }
}
