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
import FirebaseFirestore

struct Constants {
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let email = "email"
    static let uid = "uid"
    static let name = "name"
    static let avatars = "avatars"
    static let photoURL = "photoURL"
    static let messages = "messages"
    static let users = "users"
    static let recents = "recents"
    static let lastmessage = "lastmessage"
    static let conversations = "conversations"
    static let created = "created"
    static let isLogin = "isLogin"
}

class FirebaseManager{
    static let shared = FirebaseManager()
    let database = Database.database().reference()
    let storage = Storage.storage().reference()
    let fireStore = Firestore.firestore()
    
    func insertUser(_ user: UserResponse){
        guard let email = Auth.auth().currentUser?.email else { return }
        
        database.child("\(Constants.users)/\(email.safeEmail())").setValue([
            "uid": user.uid,
            "name": user.name,
            "email": user.email,
            "gender": user.gender,
            "birthday": user.birthday,
            "phone": user.phone,
            "address": user.address,
            "photoUrl": user.photoUrl
        ])
    }
    
    func updateUserProfile(
        _ values: [String: Any],
        completion: @escaping(Bool, UserResponse?, String?) -> Void
    ){
        guard let email = Auth.auth().currentUser?.email else { return}
        
        database.child(Constants.users).child(email.safeEmail()).updateChildValues(values){
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
                completion(false,nil, "Cập nhật không thành công\n Lỗi: \(error.localizedDescription)")
            } else {
                self.getUserProfile(email) { user in
                    if let user = user{
                        UserDefaultsManager.shared.save(user)
                        completion(true,user, "Cập nhật thành công!")
                    } else{
                        completion(false, nil, "Lỗi lưu thông tin người dùng")
                    }
                }
            }
        }
    }
    
    func getUserProfile(_ email: String, completion: @escaping(UserResponse?) -> Void){
        database.child("\(Constants.users)/\(email.safeEmail())").getData { error, snapshot in
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
    }
    
    func getAllUser(_ completion: @escaping([UserResponse]) -> Void){
        database.child(Constants.users).getData { error, snapshot in
            guard error == nil else {
              print(error!.localizedDescription)
                completion([])
              return
            }
            
            guard let snapshot = snapshot, snapshot.exists() else {
                completion([])
                return
            }
            
            guard let allObjects = snapshot.value as? [String : Any], allObjects.count > 0 else {
                completion([])
                return
            }
            
            var users = [UserResponse]()
            let userId = Auth.auth().currentUser?.uid
            
            allObjects.forEach { key, value in
                if let object = value as? [String: Any]{
                    if let uid = object["uid"] as? String, uid != userId{
                        let user = UserResponse(dict: object)
                        users.append(user)
                    }
                }
            }
            completion(users)
        }
    }
    
    func uploadImage(_ data: Data?, completionHandler: @escaping(Bool,_ imageName:String?,_ url:String?) -> Void){
        
        let imageName: String = String("\(Date().timeIntervalSince1970).png")
        
        guard let data = data else {
            completionHandler(false, "Không có dữ liệu", nil)
            return
        }
        
        storage.child("\(Constants.avatars)/\(imageName)").putData(data, metadata: nil) { _, error in
            guard error == nil else {
                completionHandler(false, "Lỗi cập nhật ảnh", nil)
                return
            }
            
            self.storage.child("\(Constants.avatars)/\(imageName)").downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    completionHandler(false, "Không lấy được URL", nil)
                    return
                }
                completionHandler(true,imageName,downloadURL.absoluteString)
            }
        }
    }
    
    func downloadImage(with fileName: String, completion: @escaping (UIImage?) -> Void) {
        let megaByte = Int64(1 * 1024 * 1024)
        storage.child("\(Constants.avatars)/\(fileName)").getData(maxSize: megaByte) { data, _ in
            guard let imageData = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
    }
    
    func sendImage(_ data: Data?, completionHandler: @escaping(Bool, String?) -> Void){
        
        let imageName: String = String("\(Date().timeIntervalSince1970).png")
        
        guard let data = data else {
            completionHandler(false, "Không có dữ liệu")
            return
        }
        
        storage.child("\(Constants.messages)/\(imageName)").putData(data, metadata: nil) { _, error in
            guard error == nil else {
                completionHandler(false, "Không gửi được ảnh")
                return
            }
            
            self.storage.child("\(Constants.messages)/\(imageName)").downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    completionHandler(false, "Không lấy được URL")
                    return
                }
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
    
    func sendMessage(
        sender: UserResponse,
        recipient: UserResponse,
        message: Message,
        completion: @escaping() -> Void
    ) {
        let fromId = sender.uid
        let toId = recipient.uid
        
        let document = fireStore.collection(Constants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let data = message.data()
        
        document.setData(data) { error in
           if let error = error {
               print(error)
               return
           }
           
            if let _ = data["url"]{
                self.saveRecentMessage(
                    sender,
                    recipient: recipient,
                    text: "Tin nhắn hình ảnh"
                )
            }else{
                self.saveRecentMessage(
                    sender,
                    recipient: recipient,
                    text: message.content
                )
            }
            completion()
       }
        
        let recipientMessageDocument = fireStore
            .collection(Constants.messages)
            .document(toId)
            .collection(fromId)
            .document()
        
         recipientMessageDocument.setData(data) { error in
            if let error = error {
                print(error)
                return
            }
            print("Recipient saved message as well")
        }
    }
    
    func saveRecentMessage(
        _ currentUser: UserResponse,
        recipient: UserResponse,
        text: String
    ) {
        
        let currentUserUid = currentUser.uid
        let toId = recipient.uid
        
        let document = fireStore
            .collection(Constants.conversations)
            .document(currentUserUid)
            .collection(Constants.lastmessage)
            .document(toId)
        
        let data:[String : Any] = [
            Constants.timestamp: Timestamp(),
            Constants.text: text,
            Constants.fromId: currentUserUid,
            Constants.toId: toId,
            Constants.photoURL: recipient.photoUrl ?? "",
            Constants.email: recipient.email,
            Constants.name: recipient.name
        ]
        
        document.setData(data) { error in
            if let error = error {
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        let recipient:[String : Any] = [
            Constants.timestamp: Timestamp(),
            Constants.text: text,
            Constants.fromId: currentUserUid,
            Constants.toId: toId,
            Constants.photoURL: currentUser.photoUrl ?? "",
            Constants.email: currentUser.email,
            Constants.name: currentUser.name
        ]
        
        fireStore
            .collection(Constants.conversations)
            .document(toId)
            .collection(Constants.lastmessage)
            .document(currentUserUid)
            .setData(recipient) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
    }
}
