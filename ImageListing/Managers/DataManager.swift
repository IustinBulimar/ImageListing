//
//  DataManager.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import UIKit
import RxSwift

struct DataManager {
    
    private let cacheManager = CacheManager(capacity: 100)
    private var databaseManager: DatabaseManager?
    private var apiManager: APIManager?
    
    private let backgroundScheduler = SerialDispatchQueueScheduler(qos: .background)
    
    private let disposeBag = DisposeBag()
    
    init() {
        if let url = URL(string: "https://picsum.photos/v2") {
            apiManager = APIManager(environment: url)
        }
        do {
            try databaseManager = DatabaseManager()
        } catch {
            print(error)
        }
    }
    
    func getImages(page: Int, limit: Int = 10) -> Observable<[Image]> {
        return apiManager?.getImages(page: page, limit: limit) ?? Observable.just([])
    }
    
    func fetchImage(url: URL) -> Observable<UIImage> {
        let key = url.absoluteString
        
        return Observable.just(cacheManager.get(key: key))
            .flatMap { (image) -> Observable<UIImage> in
                if let image = image {
                    return Observable.just(image)
                }
                
                return self.databaseManager!.get(key: key)
                    .flatMap { (data) -> Observable<UIImage> in
                        if let data = data,
                            let image = UIImage(data: data) {
                            return Observable.just(image)
                        }
                        
                        return APIManager.get(url: url)
                            .do(onNext: { data in
                                self.databaseManager?.save(data: data, key: key)
                                    .subscribe(onError: { error in
                                            print(error)
                                    })
                                    .disposed(by: self.disposeBag)
                            })
                            .map { UIImage(data: $0) }
                            .compactMap { $0 }
                }
        }
        .do(onNext: { image in
            self.cacheManager.save(image: image, key: key)
        })
    }
    
    
}

