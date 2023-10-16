//
//  AuthServices.swift
//  Takenoko
//
//  Created by Ngân Phan on 13/10/2023.
//

import Foundation
import KeychainSwift

class AuthServices{
  
    static var shared = AuthServices()
    
    private init(){
        print("AuthServices init")
    }
    
    enum Keys: String{
        case keyAccessToken
    }
    
    func saveAccessToken(accessToken: String){
        let keychain = KeychainSwift()
        keychain.set(accessToken, forKey: Keys.keyAccessToken.rawValue)
       
    }
    
    func getAccessToken() -> String?{
        let keychain = KeychainSwift()
        return keychain.get(Keys.keyAccessToken.rawValue)
    }
    
    func clearAccessToken(){
        let keychain = KeychainSwift()
        keychain.delete(Keys.keyAccessToken.rawValue)
    }

    var isLogged: Bool{
        let token = getAccessToken()
        return token != nil && !(token!.isEmpty)
    }
}

