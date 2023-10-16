//
//  OnBoardServices.swift
//  Takenoko
//
//  Created by Ngân Phan on 13/10/2023.
//

import Foundation
class OnBoardServices{
    static var shared = OnBoardServices()
    
    private init(){
        print("OnBoardServices init")
    }
    
    enum Keys: String{
        case keyOnBoard
    }
    
    func markOnBoarded(){
        let userDefault = UserDefaults.standard
        userDefault.setValue(true, forKey: Keys.keyOnBoard.rawValue)
    }
    
    func saveOnBoarded(){
        let userDefault = UserDefaults.standard
        userDefault.set(true, forKey: Keys.keyOnBoard.rawValue)
    }
    
    func getOnBoarded() -> Bool{
        let userDefault = UserDefaults.standard
        return userDefault.bool(forKey: Keys.keyOnBoard.rawValue)
    }
    
    var isOnBoarded: Bool{
        let isOnBoarded = getOnBoarded()
        return isOnBoarded == true
    }
}
