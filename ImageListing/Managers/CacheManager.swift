//
//  CacheManager.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import UIKit
import RxSwift

class CacheManager {
    
    private var cache = [String: UIImage]()
    private var queue = [String]()
    
    var capacity: Int
    
    init(capacity: Int) {
        self.capacity = capacity
    }

    func save(image: UIImage, key: String) {
        guard cache[key] == nil else { return }
        
        if cache.count == capacity {
            let key = queue.removeFirst()
            cache.removeValue(forKey: key)
        }
        
        queue.append(key)
        cache[key] = image
    }

    func get(key: String) -> UIImage? {
        return cache[key]
    }
    
}
