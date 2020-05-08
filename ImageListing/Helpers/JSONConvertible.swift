//
//  JSONConvertible.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 08/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import Foundation

protocol JSONConvertible: Codable {}

extension JSONConvertible {
    
    static func fromJSON(_ json: [String: Any]) throws -> Self {
        let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
    func asJSON() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
    }
    
}
