//
//  Message.swift
//  Takenoko
//
//  Created by Ngân Phan on 25/10/2023.
//


import Foundation
import UIKit
import FirebaseFirestore
import MessageKit


struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
    init(imageURL: URL) {
      url = imageURL
      size = CGSize(width: 240, height: 240)
      placeholderImage = UIImage()
    }
}

struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}

struct Message: MessageType {
    let id: String?
    var messageId: String {
        return id ?? UUID().uuidString
    }
    let content: String
    let sentDate: Date
    let sender: SenderType
    
    var kind: MessageKind {
        if let downloadURL = downloadURL{
            let mediaItem = ImageMediaItem(imageURL: downloadURL)
            return .photo(mediaItem)
            
        } else if let image = image{
            let mediaItem = ImageMediaItem(image: image)
            return .photo(mediaItem)
            
        }else{
            return .text(content)
        }
    }
    
    var image: UIImage?
    var downloadURL: URL?
    
    init(user: UserResponse, content: String) {
        let name = user.name
        let displayName = name.isEmpty ? user.email : name
        sender = Sender(senderId: user.uid, displayName: displayName)
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    init(user: UserResponse, image: UIImage) {
        let name = user.name
        let displayName = name.isEmpty ? user.email : name
        sender = Sender(senderId: user.uid, displayName: displayName)
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard
            let sentDate = data["created"] as? Timestamp,
            let senderId = data["senderId"] as? String,
            let senderName = data["senderName"] as? String
        else {
            return nil
        }
        
        id = document.documentID
        
        self.sentDate = sentDate.dateValue()
        sender = Sender(senderId: senderId, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
        } else {
            return nil
        }
    }
}

// MARK: - DatabaseRepresentation
extension Message{
    
    func data() -> [String: Any]{
        var rep: [String: Any] = [
            "created": sentDate,
            "senderId": sender.senderId,
            "senderName": sender.displayName
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
}

// MARK: - Comparable
extension Message: Comparable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
