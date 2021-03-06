//
//  APIService.swift
//  KakaoImageSearch
//
//  Created by jc.kim on 3/5/21.
//

import Foundation
import RxSwift

let SEARCH_IMAGE_URL = "https://dapi.kakao.com/v2/search/image"
let API_KEY = "KakaoAK babff94d55071a0898f77b445ffd368d"


class APIService {
 
    static func searchImage(query: String = "", page: Int = 1,_ sort: String = "accuracy",_ size: Int = 30, onComplete: @escaping (Result<[Document], Error>) -> Void) {
        guard query != "" else { return }
        
        let parameters = [
            "query":query,
            "sort": sort,
            "page":"\(page)",
            "size":"\(size)"
        ]
        
        var components = URLComponents(string: SEARCH_IMAGE_URL)!
        components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(API_KEY, forHTTPHeaderField: "Authorization")
                
        URLSession.shared.dataTask(with: request) { data, res, err in
            if let err = err {
                onComplete(.failure(err))
                return
            }
            
            guard let data = data else {
                let httpResponse = res as! HTTPURLResponse
                onComplete(.failure(NSError(domain: "no data", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            guard let response = try? JSONDecoder().decode(SearchImage.self, from: data) else {
                onComplete(.failure(NSError(domain: "Decoding error", code: -1000, userInfo: nil)))
                return
            }
            
            onComplete(.success(response.documents))
        }.resume()
    }
    
    
    
    static func searchImageRx(_ query: String,_ page: Int = 1) -> Observable<[Document]> {
        return Observable.create { emitter in
            searchImage(query: query, page: page) { result in
                switch result {
                case let .success(documents):
                    emitter.onNext(documents)
                    emitter.onCompleted()
                case let .failure(error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
       
}

