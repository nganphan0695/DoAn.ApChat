//
//  Setting.swift
//  Takenoko
//
//  Created by Ngân Phan on 18/10/2023.
//

import Foundation
import UIKit

enum SettingItem: Int {
    case notification = 0
    case security
    case help
    case darkMode
    case logOut
    
    func tittle() -> String{
        switch self{
        case .notification:
            return "Thông báo"
        case .security:
            return "Bảo mật"
        case .help:
            return "Trợ giúp"
        case .darkMode:
            return "Giao diện"
        case .logOut:
            return "Đăng xuất"
        }
    }
    
    func image() -> UIImage?{
        switch self{
        case .notification:
            return UIImage(systemName: "bell")
        case .security:
            return UIImage(systemName: "lock")
        case .help:
            return UIImage(systemName: "questionmark.circle")
        case .darkMode:
            return UIImage(systemName: "moon")
        case .logOut:
            return UIImage(systemName: "rectangle.portrait.and.arrow.right")
        }
    }
    
    func isHiddenButton() -> Bool{
        switch self{
        case .notification, .security, .help:
            return false
        default:
            return true
        }
    }
}
