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
    
    private let cacheManager = CacheManager<UIImage>(capacity: 100)
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
    
    private func getImages(page: Int, limit: Int = 10) -> Observable<[Image]> {
        return (self.apiManager?.getImages(page: page, limit: limit) ?? Observable.just([]))
            .do(onNext: { images in
                for image in images {
                    self.databaseManager?.save(model: image)
                        .subscribe(onError: { error in
                            print(error)
                        })
                        .disposed(by: self.disposeBag)
                }
            })
    }
    
    func fetchImages(page: Int, limit: Int = 10) -> Observable<[Image]> {
        if page > 1 {
            return getImages(page: page, limit: limit)
        }
        
        return (databaseManager?.getAll() ?? Observable<[Image]>.just([]))
            .flatMap { (images) -> Observable<[Image]> in
                if images.count > 0 {
                    return Observable.just(images)
                }
                
                return self.getImages(page: page, limit: limit)
        }
    }
    
    private func getImage(url: URL) -> Observable<UIImage> {
        let key = url.absoluteString
        
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
            .do(onNext: { image in
                self.cacheManager.save(image, key: key)
            })
    }
    
    func fetchImage(url: URL) -> Observable<UIImage> {
        let key = url.absoluteString
        
        if let image = cacheManager.get(key: key) {
            return Observable.just(image)
        }
        
        guard let databaseManager = databaseManager else {
            return getImage(url: url)
        }
        
        return databaseManager.get(key: key)
            .flatMap { (data) -> Observable<UIImage> in
                if let data = data,
                    let image = UIImage(data: data) {
                    return Observable.just(image)
                        .do(onNext: { image in
                            self.cacheManager.save(image, key: key)
                        })
                }
                
                return self.getImage(url: url)
        }
    }
    
}

