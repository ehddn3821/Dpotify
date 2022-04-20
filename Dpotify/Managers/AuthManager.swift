//
//  AuthManager.swift
//  Dpotify
//
//  Created by dwKang on 2022/04/18.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    struct Constants {
        static let clientID = "aa4fe5ab8b4e4a91a03db10da745f5e7"
        static let clientSecret = "9d6f2aacc28f4c76bf11f1e2fed37666"
    }
    
    public var signInURL: URL? {
        let scope = "user-read-private"
        let redirectURI = "https://iosacademy.io/"
        let baseUrl = "https://accounts.spotify.com/authorize?"
        let parameters = "response_type=code&client_id=\(Constants.clientID)&scope=\(scope)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        return URL(string: baseUrl + parameters)
    }
    
    var isSignedIn: Bool {
        return false
    }
    
    private var accessToken: String? {
        return nil
    }
    
    private var refreshToken: String? {
        return nil
    }
    
    private var tokenExpirationDate: Date? {
        return nil
    }
    
    private var shouldRefreshToken: Bool {
        return false
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        // Get token
    }
    
    public func refreshAccessToken() {
        
    }
    
    public func cacheToken() {
        
    }
}
