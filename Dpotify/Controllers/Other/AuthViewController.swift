//
//  AuthViewController.swift
//  Dpotify
//
//  Created by dwKang on 2022/04/18.
//

import UIKit
import WebKit
import SnapKit

class AuthViewController: BaseViewController {
    
    public var completionHandler: ((Bool) -> Void)?
    
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
        
        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value else { return }
        
        print("Code: \(code)")
    }
}
