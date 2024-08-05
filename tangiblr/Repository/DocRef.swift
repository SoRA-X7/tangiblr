//
//  DocRef.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/03.
//

import Foundation

public struct DocRef<T>: Identifiable {
    public let id: String
    public let data: T
    
    init(_ id: String, _ data: T) {
        self.id = id
        self.data = data
    }
}

