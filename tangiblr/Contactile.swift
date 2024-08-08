//
//  Contactile.swift
//  tangiblr
//
//  Created by SoRA_X7 on 2024/08/07.
//

import Foundation

struct Contactile: Codable {
    var dim: [Int]
    var ext: [DetoursExtension]
    
    init(data1D: [Float]) {
        self.dim = [data1D.count]
        self.ext = [
            DetoursExtension(data: data1D)
        ]
    }
    
    public func toString() throws -> String {
        let json = try JSONEncoder().encode(self)
        
        return String(data: json, encoding: .utf8)!
    }
    
    public static func fromJSON(_ json: String) throws -> Contactile {
        return try JSONDecoder().decode(Contactile.self, from: Data(json.utf8))
    }
}

struct DetoursExtension : Codable{
    var data: [Float]
}
