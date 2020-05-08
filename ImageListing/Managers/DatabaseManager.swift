//
//  DatabaseManager.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import Foundation
import RxSwift
import CouchbaseLite


struct DatabaseManager {
    
    private var database: CBLDatabase
    
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .background)
    
    init() throws {
        database = try CBLDatabase(name: "database")
    }
    
    func save(data: Data, key: String) -> Observable<Void> {
        return Observable.create { observer in
            let doc = CBLMutableDocument(id: key)
            doc.setBlob(CBLBlob(contentType: "image/jpg", data: data), forKey: "imageData")
            do {
                try self.database.save(doc)
                observer.onNext(())
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
        .subscribeOn(backgroundScheduler)
    }
    
    func get(key: String) -> Observable<Data?> {
        return Observable.just(self.database.document(withID: key)?.blob(forKey: "imageData")?.content)
            .subscribeOn(backgroundScheduler)
    }
    
}
