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


//query    String    검색을 원하는 질의어    O
//sort    String    결과 문서 정렬 방식, accuracy(정확도순) 또는 recency(최신순), 기본 값 accuracy    X
//page    Integer    결과 페이지 번호, 1~50 사이의 값, 기본 값 1    X
//size    Integer    한 페이지에 보여질 문서 수, 1~80 사이의 값, 기본 값 80



class APIService {
    
    static func searchImageRx(_ query: String = "",_ page: Int = 1) -> Observable<[Document]> {
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
    
    
    
    enum Sort: String {
        case accuracy
        case recency
    }
    
    static func searchImage(query: String = "", page: Int = 1,_ sort: String = Sort.accuracy.rawValue,_ size: Int = 80, onComplete: @escaping (Result<[Document], Error>) -> Void) {
        
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
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(API_KEY, forHTTPHeaderField: "Authorization")
//        request.timeoutInterval = 20000.0
        
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
                onComplete(.failure(NSError(domain: "Decoding error", code: -1, userInfo: nil)))
                return
            }
            onComplete(.success(response.documents))
        }.resume()
    }
    
    
    
    
    
    
}

