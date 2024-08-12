//
//  Post.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/07/29.
//

import Foundation
import Firebase

public struct Post : Codable, Equatable {
    public var user: String
    public var description: String
    public var images: [String]
    public var contactile: String
    public var timestamp: Date
    //    public var createdAt: Date
    //    public var updatedAt: Date
    
    init(_ description: String) {
        self.description = description
        self.user = "test001"
        //        self.createdAt = Date()
        //        self.updatedAt = self.createdAt
        self.images = [""]
        self.contactile = ""
        self.timestamp = Date()
    }
    
    public static func fetchFromFirestore() async throws -> [DocRef<Post>] {
        let firestore = Firestore.firestore()
        
        let docs = try await firestore.collection("posts").order(by: "timestamp", descending: true).getDocuments()
        
        return try docs.documents.map({ d in
            try DocRef(d.documentID, d.data(as: Post.self))
        })
    }
    
    public static func load(_ documentId: String) async throws -> Post {
        let firestore = Firestore.firestore()
        let doc = try await firestore.collection("posts").document(documentId).getDocument(as: Post.self)
        
        return doc
    }
}
