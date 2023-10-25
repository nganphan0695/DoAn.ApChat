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
    var uid: String
    var name: String
    var email: String
    var gender: String
    var birthday: String
    var phone: String
    var address: String
    var photoUrl: String?
    var photoName: String?
    
    init(
        uid: String,
        name: String,
        email: String,
        gender: String,
        birthday: String,
        phone: String,
        address: String,
        photoUrl: String,
        photoName: String?
    ){
        self.uid = uid
        self.name = name
        self.email = email
        self.gender = gender
        self.birthday = birthday
        self.phone = phone
        self.address = address
        self.photoUrl = photoUrl
        self.photoName = photoName
    }
    
    init(dict:[String : Any]) {
        
        let uid = dict["uid"] as? String ?? ""
        let address = dict["address"] as? String ?? ""
        let birthday = dict["birthday"] as? String ?? ""
        let email = dict["email"] as? String ?? ""
        let gender = dict["gender"] as? String ?? ""
        let name = dict["name"] as? String ?? ""
        let phone = dict["phone"] as? String ?? ""
        let photoUrl = dict["photoUrl"] as? String ?? ""
        let photoName = dict["photoName"] as? String ?? ""
        
        self.uid = uid
        self.address = address
        self.birthday = birthday
        self.email = email
        self.gender = gender
        self.name = name
        self.phone = phone
        self.photoUrl = photoUrl
        self.photoName = photoName
    }
}

extension String{
    func safeEmail() -> Self{
        let safeEmail = self.replacingOccurrences(of: ".", with: "_")
        let replace = safeEmail.replacingOccurrences(of: "@", with: "-")
        return replace
    }
}
