//
//  ImageView.swift
//  DFGithub
//
//  Created by David FU on 2025/5/10.
//

import UIKit

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
