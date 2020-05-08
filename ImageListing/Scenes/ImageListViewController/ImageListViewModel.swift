//
//  ImageListViewModel.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import Foundation
import RxSwift

class ImageListViewModel {
    
    let dataManager = DataManager()
    
    var images =  [Image]()
    
    private var page = 0
    
    private var finishedPages = false
    
    
    func loadNextPage() -> Observable<Bool> {
        guard !finishedPages else {
            return Observable.just(false)
        }
        
        page += 1
        
        return dataManager.getImages(page: page)
            .do(onNext: { [weak self] images in
                guard images.count > 0 else {
                    self?.finishedPages = true
                    return
                }
                self?.images += images
            })
            .map { _ in true }
    }
    
    func loadImage(url: URL) -> Observable<UIImage> {
        return dataManager.fetchImage(url: url)
    }
    
}
