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
    
    enum Sort: String {
        case accuracy
        case recency
    }
    
    
    static func searchImage(_ query: String = "",_ sort: String = Sort.accuracy.rawValue,_ page: Int = 1,_ size: Int = 80) -> Observable<[Document]> {
        
        return Observable.create { emitter in
            let parameters = [
                "query":query,
                "sort": sort,
                "page":"\(page)",
                "size":"\(size)"
            ]
            
            var components = URLComponents(string: SEARCH_IMAGE_URL)!
            components.queryItems = parameters.map { URLQueryItem(name: $0, value: $1) }
            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            
            let request = URLRequest(url: components.url!)
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    emitter.onError(error)
                    return
                }
                
                guard let data = data,
                      let members = try? JSONDecoder().decode(SearchImage.self, from: data) else {
                    emitter.onCompleted()
                    return
                }
            
                emitter.onNext(members.documents)
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

