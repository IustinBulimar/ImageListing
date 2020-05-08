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
    
    
    // MARK: - Generic Model
    
    func save<Model: JSONConvertible>(model: Model) -> Observable<Void> {
        return Observable.create { observer in
            do {
                let doc = CBLMutableDocument(id: nil)
                doc.setValuesForKeys(try model.asJSON())
                doc.setString("\(Model.self)", forKey: "type")
                try self.database.save(doc)
                observer.onNext(())
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
        .subscribeOn(backgroundScheduler)
    }
    
    func get<Model: JSONConvertible>(key: String) -> Observable<Model> {
        let json = self.database.document(withID: key)?.toDictionary() ?? [:]
        do {
            return Observable.just(try Model.fromJSON(json))
        } catch {
            return Observable.error(error)
        }
    }
    
    func getAll<Model: JSONConvertible>() -> Observable<[Model]> {
        let condition = CBLQueryExpression.property("type")
            .equal(to: CBLQueryExpression.string("\(Model.self)"))
        let query = CBLQueryBuilder.select([CBLQuerySelectResult.all()],
                                           from: CBLQueryDataSource.database(database),
                                           where: condition)
        
        do {
            let results = try query.execute().allResults() ?? []
            let models: [Model] = try results
                .compactMap  { $0.value(forKey: "database") as? CBLDictionary }
                .map { try Model.fromJSON($0.toDictionary()) }
            
            return Observable.just(models)
                .subscribeOn(backgroundScheduler)
            
        } catch {
            return Observable.error(error)
        }
    }
    
}
