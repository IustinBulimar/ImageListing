//
//  APIManager.swift
//  ImageListing
//
//  Created by Iustin Bulimar on 07/05/2020.
//  Copyright © 2020 Iustin Bulimar. All rights reserved.
//

import Foundation
import RxSwift

typealias APIRoute = String

extension APIRoute {
    static let imageList = "list"
}

enum APIError: Error {
    
    case invalidUrl
    case badResponse
    case validation(statusCode: Int)
    case wrongMimeType
    case noData
    case badModelDecoding
    case generic(description: String)
    
    init(error: Error) {
        self = .generic(description: error.localizedDescription)
    }
    
}

struct APIManager {

    var environment: URL
    
    func getImages(page: Int, limit: Int) -> Observable<[Image]> {
        return get(route: .imageList, params: [ "page": page, "limit": limit ])
    }
    
    
    // MARK: - Generic
    
    static func get(url: URL, params: [String: Any]? = nil) -> Observable<Data> {
        return Observable.create { observer in
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            urlComponents?.queryItems = params?.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            
            guard let url = urlComponents?.url else {
                observer.onError(APIError.invalidUrl)
                return Disposables.create()
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    observer.onError(APIError(error: error!))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(APIError.badResponse)
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    observer.onError(APIError.validation(statusCode: httpResponse.statusCode))
                    return
                }
                
                guard let data = data else {
                    observer.onError(APIError.noData)
                    return
                }
                
                observer.onNext(data)
                
            }.resume()
            
            return Disposables.create()
        }
        .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
    }
    
    static func get<Model: Codable>(url: URL, params: [String: Any]? = nil) -> Observable<Model> {
        return get(url: url, params: params)
            .map { data in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let model = try decoder.decode(Model.self, from: data)
                return model
        }
    }
    
    func get<Model: Codable>(route: APIRoute, params: [String: Any]? = nil) -> Observable<Model> {
        return APIManager.get(url: environment.appendingPathComponent(route), params: params)
    }
    
}


