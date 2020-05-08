//
//  CacheManager.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import UIKit
import RxSwift

class CacheManager<Item: Any> {
    
    private var cache = [String: Item]()
    private var queue = [String]()
    
    var capacity: Int
    
    init(capacity: Int) {
        self.capacity = capacity
    }

    func save(_ item: Item, key: String) {
        guard cache[key] == nil else { return }
        
        if cache.count == capacity {
            let key = queue.removeFirst()
            cache.removeValue(forKey: key)
        }
        
        queue.append(key)
        cache[key] = item
    }

    func get(key: String) -> Item? {
        return cache[key]
    }
    
}
