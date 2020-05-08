//
//  Image.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import Foundation

struct Image: Codable {
    
    var id: String
    var author: String
    var width: Double
    var height: Double
    var url: URL
    var downloadUrl: URL
    
    
    func downloadUrl(width: Int, height: Int? = nil) -> URL {
        return downloadUrl
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("\(Int(width))")
            .appendingPathComponent("\(height ?? Int(Double(width) / self.width))")
    }
    
}
