//
//  FirebaseManager.swift
//  Takenoko
//
//  Created by Ngân Phan on 18/10/2023.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FirebaseManager{
    static let shared = FirebaseManager()
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
//    let storage = Storage.storage().reference()
    
    func insertUser(_ user: UserResponse){
        guard let email = Auth.auth().currentUser?.email else { return }
        
        database.child("users/\(email.safeEmail())").setValue([
            "name": user.name,
            "email": user.email,
            "gender": user.gender,
            "birthday": user.birthday,
            "phone": user.phone,
            "address": user.address
        ])
    }
    
    func updateUserProfile(
        _ user: UserResponse,
        completion: @escaping(Bool, String?) -> Void
    ){
        guard let email = Auth.auth().currentUser?.email else { return }
//        guard let image = Auth.auth().currentUser?.photoURL else {return}
        
        database.child("users").child(email.safeEmail()).setValue([
            "name": user.name,
            "email": user.email,
            "gender": user.gender,
            "birthday": user.birthday,
            "phone": user.phone,
            "address": user.address
        ]
        ){ (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
                completion(false,"Cập nhật không thành công\n Lỗi: \(error.localizedDescription)")
            } else {
                completion(true,"Cập nhật thành công!")
                print("Data saved successfully!")
            }
        }
     
//        storage.child("user_images/\(image)").putData(image, metadata: nil) { _, error in
//            guard error == nil else {
//                return
//            }
//            self.storage.child("user_images/\(image)").downloadURL { url, error in
//                guard let downloadURL = url, error == nil else {
//                    return
//                }
//
//                self.storage.child("user_images/\(image)").setValue(downloadURL.absoluteString)
//        }
    }
    
    func getUserProfile(completion: @escaping(UserResponse?) -> Void){
        if let email = Auth.auth().currentUser?.email{
            database.child("users/\(email.safeEmail())").getData { error, snapshot in
                guard error == nil else {
                  print(error!.localizedDescription)
                    completion(nil)
                  return
                }
                
                guard let value = snapshot?.value, let exists = snapshot?.exists(), exists else {
                    completion(nil)
                    return
                }
                
                guard let data = try? JSONSerialization.data(withJSONObject: value as Any, options: []) else {
                    completion(nil)
                    return
                }
                do {
                    let user = try JSONDecoder().decode(UserResponse.self, from: data)
                    completion(user)
                } catch let error{
                    print(error.localizedDescription)
                    completion(nil)
                }
            }
        }else{
            completion(nil)
        }
    }
    
    func uploadImage(_ data: Data?, completionHandler: @escaping(Bool, String?) -> Void){
        
        let imageName: String = String("\(Date().timeIntervalSince1970).png")
        
        guard let data = data else {
            completionHandler(false, "Không có dữ liệu")
            return
        }
        
        storage.child("user_images/\(imageName)").putData(data, metadata: nil) { _, error in
            guard error == nil else {
                completionHandler(false, "Lỗi cập nhật ảnh")
                return
            }
            
            self.storage.child("user_images/\(imageName)").downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    completionHandler(false, "Không lấy được URL")
                    return
                }
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = downloadURL
                changeRequest?.commitChanges { error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                }
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
}
