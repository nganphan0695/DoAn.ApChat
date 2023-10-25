//
//  UserDefaultsManager.swift
//  Takenoko
//
//  Created by Ngân Phan on 25/10/2023.
//

import Foundation

class UserDefaultsManager{
    
    static let shared = UserDefaultsManager()
    
    func getUser() -> UserResponse?{
        if let data = UserDefaults.standard.data(forKey: Constants.users) {
            do {
                let decoder = JSONDecoder()
                let user = try decoder.decode(UserResponse.self, from: data)
                return user
            } catch {
                print("Unable to Decode Note (\(error))")
                return nil
            }
        }else{
            return nil
        }
    }
    
    func remove(){
        UserDefaults.standard.set(nil, forKey: Constants.users)
        UserDefaults.standard.removeObject(forKey: Constants.users)
        UserDefaults.standard.removeObject(forKey: Constants.isLogin)
    }

    func save(_ user: UserResponse?){
        guard let user = user else { return }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            UserDefaults.standard.set(data, forKey: Constants.users)
        } catch {
            print("Unable to Encode Note (\(error))")
        }
    }

    func setIsLogin(_ isLogin: Bool){
        UserDefaults.standard.setValue(true, forKey: Constants.isLogin)
    }

    func getLoginStatus() -> Bool?{
        if let isLogin = UserDefaults.standard.value(forKey: Constants.isLogin) as? Bool{
            return isLogin
        }else{
            return nil
        }
    }
    
}
