//
//  Conversation.swift
//  Takenoko
//
//  Created by Ngân Phan on 23/10/2023.
//
import FirebaseFirestore
import Foundation

struct Conversation{
    var id: String?
    let text, email: String
    let fromId, toId: String
    let photoUrl: String?
    let timeStamp: Timestamp
    let name: String?
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
}
