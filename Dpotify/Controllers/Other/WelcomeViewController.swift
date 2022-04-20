//
//  WelcomeViewController.swift
//  Dpotify
//
//  Created by dwKang on 2022/04/18.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class WelcomeViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    
    private let signInButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.setTitle("Sign In with Spotify", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        return btn
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    func setupUI() {
        title = "Dpotify"
        view.backgroundColor = .systemGreen
        
        view.addSubview(signInButton)
        signInButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaInsets.bottom).offset(-50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(50)
        }
    }
    
    func buttonActions() {
        signInButton.rx.tap.bind { [weak self] _ in
            let vc = AuthViewController()
            vc.completionHandler = { [weak self] success in
                DispatchQueue.main.async {
                    self?.handleSignIn(success: success)
                }
            }
            vc.navigationItem.largeTitleDisplayMode = .never
            self?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func handleSignIn(success: Bool) {
        // Log user in or yell at them for error
    }
}
