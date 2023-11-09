//
//  Conversation.swift
//  Takenoko
//
//  Created by Ngân Phan on 23/10/2023.
//
import FirebaseFirestore
import Foundation

class Conversation{
    var id: String?
    let text, email: String
    let fromId, toId: String
    let photoUrl: String?
    let timeStamp: Timestamp
    let name: String?
    var isLock: Bool = false
    var password: String = ""
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    init(
        id: String? = nil,
        text: String,
        email: String,
        fromId: String,
        toId: String,
        photoUrl: String?,
        timeStamp: Timestamp,
        name: String?,
        isLock: Bool,
        password: String
    ) {
        self.id = id
        self.text = text
        self.email = email
        self.fromId = fromId
        self.toId = toId
        self.photoUrl = photoUrl
        self.timeStamp = timeStamp
        self.name = name
        self.isLock = isLock
        self.password = password
    }
}

