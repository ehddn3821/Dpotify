//
//  AuthManager.swift
//  Dpotify
//
//  Created by dwKang on 2022/04/18.
//

import Foundation
import RxCocoa

final class AuthManager {
    
    static let shared = AuthManager()
    
    struct Constants {
        static let clientID = "aa4fe5ab8b4e4a91a03db10da745f5e7"
        static let clientSecret = "9d6f2aacc28f4c76bf11f1e2fed37666"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://iosacademy.io/"
        static let scope = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    let isExchangeCode = PublishRelay<Bool>()
    let isRefreshNeed = BehaviorRelay<Bool>(value: false)
    
    public var signInURL: URL? {
        let baseUrl = "https://accounts.spotify.com/authorize?"
        let parameters = "response_type=code&client_id=\(Constants.clientID)&scope=\(Constants.scope)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: baseUrl + parameters)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let tokenExpirationDate = tokenExpirationDate else {
            return false
        }
        
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300

        return currentDate.addingTimeInterval(fiveMinutes) >= tokenExpirationDate
    }
    
    public func exchangeCodeForToken(code: String) {
        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            isExchangeCode.accept(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else {
                self.isExchangeCode.accept(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.cacheToken(result: result)
                self.isExchangeCode.accept(true)
            }
            catch {
                print(error.localizedDescription)
                self.isExchangeCode.accept(false)
            }
        }
        task.resume()
    }
    
    public func refreshIfNeeded() {
//        guard shouldRefreshToken else {
//            isRefreshNeed.accept(true)
//            return
//        }
        
        guard let refreshToken = refreshToken else {
            return
        }

        guard let url = URL(string: Constants.tokenAPIURL) else { return }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            isExchangeCode.accept(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            guard let data = data, error == nil else {
                self.isExchangeCode.accept(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("Successfully refreshed token")
                self.cacheToken(result: result)
                self.isExchangeCode.accept(true)
            }
            catch {
                print(error.localizedDescription)
                self.isExchangeCode.accept(false)
            }
        }
        task.resume()
    }
    
    public func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refreshToken = result.refresh_token {
            UserDefaults.standard.setValue(refreshToken, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
}
