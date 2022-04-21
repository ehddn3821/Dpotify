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
            guard let self = self else { return}
            
            let vc = AuthViewController()
            
            vc.isSignInSuccess
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { isSuccess in
                    if isSuccess {
                        let mainAppTabBarVC = TabBarViewController()
                        mainAppTabBarVC.modalPresentationStyle = .fullScreen
                        self.present(mainAppTabBarVC, animated: true)
                    }
                    else {
                        let alert = UIAlertController(title: "Oops",
                                                      message: "Something went wrong when signing in.",
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                        self.present(alert, animated: true)
                    }
                }).disposed(by: self.disposeBag)
            
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
}
