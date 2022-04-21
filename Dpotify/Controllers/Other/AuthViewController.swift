//
//  AuthViewController.swift
//  Dpotify
//
//  Created by dwKang on 2022/04/18.
//

import UIKit
import WebKit
import SnapKit
import RxCocoa
import RxSwift

class AuthViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let isSignInSuccess = PublishRelay<Bool>()
    
    private let webView: WKWebView = {
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        let config = WKWebViewConfiguration()
        config.preferences = prefs
        let wv = WKWebView(frame: .zero, configuration: config)
        return wv
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        guard let url = AuthManager.shared.signInURL else { return }
        webView.load(URLRequest(url: url))
    }
    
    func setupUI() {
        title = "Sign In"
        view.backgroundColor = .systemBackground
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let url = webView.url else { return }
        
        AuthManager.shared.isExchangeCode
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSuccess in
                self?.navigationController?.popViewController(animated: true)
                self?.isSignInSuccess.accept(isSuccess)
            }).disposed(by: disposeBag)
        
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value else { return }
        
        AuthManager.shared.exchangeCodeForToken(code: code)
    }
}
