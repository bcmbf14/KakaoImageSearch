//
//  ViewModel.swift
//  KakaoImageSearch
//
//  Created by jc.kim on 3/6/21.
//

import Foundation
import RxSwift
import RxCocoa

class ImageItemsViewModel {
    
//    let menuItems$: BehaviorRelay<[(menu: MenuItem, count: Int)]> = BehaviorRelay(value: [])

    var page = 1{
        didSet{
//            print("")
//            print(#function, "page : \(page)")
//            print("")
        }
    }
    
    lazy var searchBarObservable : BehaviorRelay<(String, Int)> = BehaviorRelay(value: ("", page))
    
    let searchImageItems: BehaviorRelay<[Document]> = BehaviorRelay(value: [])
    
    

    var disposeBag = DisposeBag()

    init() {
        
        searchBarObservable
//            .filter{$0.0 != nil}
//            .map{($0.0!,$0.1)}
//            .debug()
            .flatMap(APIService.searchImageRx)
            .map(appendItems)
//            .subscribe()
            .bind(to: searchImageItems)
//            .asDriver(onErrorJustReturn: [])
//            .map(appendItems)
//            .drive(searchImageItems)
//            .bind(to: searchImageItems)
            
            .disposed(by: disposeBag)
        
            
        
    }
    
    var totalItems = [Document]()
    
    private func appendItems(_ items: [Document]) -> [Document]{
        self.totalItems.append(contentsOf: items)
        return totalItems
    }
}

