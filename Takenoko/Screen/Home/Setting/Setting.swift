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
    case resetPassword
    case introduce
    case darkMode
    case logOut
    
    func tittle() -> String{
        switch self{
        case .notification:
            return "Thông báo"
        case .resetPassword:
            return "Đổi mật khẩu"
        case .introduce:
            return "Giới thiệu"
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
        case .resetPassword:
            return UIImage(systemName: "lock")
        case .introduce:
            return UIImage(systemName: "questionmark.circle")
        case .darkMode:
            return UIImage(systemName: "moon")
        case .logOut:
            return UIImage(systemName: "rectangle.portrait.and.arrow.right")
        }
    }
    
    func isHiddenButton() -> Bool{
        switch self{
        case .notification, .resetPassword, .introduce:
            return false
        default:
            return true
        }
    }
}
