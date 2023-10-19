//
//  Profile.swift
//  Takenoko
//
//  Created by Ngân Phan on 15/10/2023.
//

import Foundation

enum ProfileItem: Int {
    case name = 0
    case email
    case gender
    case birthday
    case phone
    case address
    
    func tittle() -> String{
        switch self{
        case .name:
            return "Tên"
        case .email:
            return "Email"
        case .gender:
            return "Giới tính"
        case .birthday:
            return "Ngày sinh"
        case .phone:
            return "Số điện thoại"
        case .address:
            return "Địa chỉ"
        }
    }
    
    func isHiddenRequired() -> Bool{
        switch self{
        case .name, .email:
            return false
        default:
            return true
        }
    }
    
//    func isHiddenErrorView() -> Bool{
//        switch self{
//        case .name, .email:
//            return false
//        default:
//            return true
//        }
//    }
}


class Profile{
    var item: ProfileItem
    var value: String
    
    init(item: ProfileItem, value: String) {
        self.item = item
        self.value = value
    }
}

struct UserResponse: Codable{
    var name: String
    var email: String
    var gender: String
    var birthday: String
    var phone: String
    var address: String
}

extension String{
    func safeEmail() -> Self{
        let safeEmail = self.replacingOccurrences(of: ".", with: "_")
        let replace = safeEmail.replacingOccurrences(of: "@", with: "-")
        return replace
    }
}
