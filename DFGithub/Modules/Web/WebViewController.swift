//
//  WebViewController.swift
//  闪
//
//  Created by 傅斌 on 2023/7/24.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit

class WebViewController: ViewController {
    
    lazy var rightBarButton: BarButtonItem = {
        let view = BarButtonItem(image: R.image.icon_navigation_web(), style: .done, target: nil, action: nil)
        return view
    }()
    
    lazy var goBackBarButton: BarButtonItem = {
        let view = BarButtonItem(image: R.image.icon_navigation_back(), style: .done, target: nil, action: nil)
        return view
    }()
    
    lazy var goForwardBarButton: BarButtonItem = {
        let view = BarButtonItem(image: R.image.icon_navigation_forward(), style: .done, target: nil, action: nil)
        return view
    }()
    
    lazy var stopReloadBarButton: BarButtonItem = {
        let view = BarButtonItem(image: R.image.icon_navigation_refresh(), style: .done, target: nil, action: nil)
        return view
    }()
    
    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        view.uiDelegate = self
        return view
    }()
    
    lazy var toolbar: Toolbar = {
        let view = Toolbar()
        view.items = [self.goBackBarButton, self.goForwardBarButton, self.spaceBarButton, self.stopReloadBarButton]
        return view
    }()
    
    override func makeUI() {
        super.makeUI()
        
        navigationItem.rightBarButtonItem = rightBarButton
        stackView.insertArrangedSubview(webView, at: 0)
        stackView.addArrangedSubview(toolbar)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        guard let viewModel = viewModel as? WebViewModel else { return }
        
        let input = WebViewModel.Input(rightBarButtonClick: rightBarButton.rx.tap.throttleForUI().mapToVoid(),
                                       goBackBarButtonClick: goBackBarButton.rx.tap.throttleForUI().mapToVoid(),
                                       goFowardBarButtonClick: goForwardBarButton.rx.tap.throttleForUI().mapToVoid(),
                                       stopReloadBarButtonClick: stopReloadBarButton.rx.tap.throttleForUI().mapToVoid())
        let output = viewModel.transform(input: input)
        
        output
            .didURLShouldLoad
            .drive(onNext: { [weak self] url in
                guard let self = self else { return }
                webView.load(URLRequest(url: url))
            })
            .disposed(by: rx.disposeBag)
        
        output
            .didRightBarButtonClick
            .drive(onNext: { [weak self] url in
                guard let self = self else { return }
                self.navigator.show(segue: .safari(url), sender: self)
            })
            .disposed(by: rx.disposeBag)
        
        output
            .didGoBackBarButtonClick
            .drive(onNext: { [weak self] url in
                guard let self = self else { return }
                self.webView.goBack()
            })
            .disposed(by: rx.disposeBag)
        
        output
            .didGoFowardBarButtonClick
            .drive(onNext: { [weak self] url in
                guard let self = self else { return }
                self.webView.goForward()
            })
            .disposed(by: rx.disposeBag)
        
        output
            .didStopReloadBarButtonClick
            .drive(onNext: { [weak self] url in
                guard let self = self else { return }
                if self.webView.isLoading {
                    webView.stopLoading()
                } else {
                    webView.reload()
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    override func updateUI() {
        super.updateUI()
        goBackBarButton.isEnabled = webView.canGoBack
        goForwardBarButton.isEnabled = webView.canGoForward
        stopReloadBarButton.image = webView.isLoading ? R.image.icon_navigation_stop(): R.image.icon_navigation_refresh()
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //self.url.accept(webView.url)
        updateUI()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateUI()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateUI()
    }
}

extension WebViewController: WKUIDelegate {
    
}
