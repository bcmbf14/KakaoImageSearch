//
//  ImageCollectionViewCell.swift
//  KakaoImageSearch
//
//  Created by jc.kim on 3/5/21.
//

import UIKit
import RxSwift

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ImageCollectionViewCell"
    
    @IBOutlet var searchImageView: UIImageView!
    
    var disposeBag = DisposeBag()
    
    func setData(_ data: Document) {
        loadImage(from: data.imageURL)
            .asDriver(onErrorJustReturn: UIImage(systemName: "photo"))
            .drive(searchImageView.rx.image)
            .disposed(by: disposeBag)
        
        searchImageView.image = nil
    }

    private func loadImage(from url: String) -> Observable<UIImage?> {
        return Observable.create { emitter in
            guard let url = URL(string: url) ?? nil else {
                print("Invalid URL")
                emitter.onNext(UIImage(systemName: "photo"))
                return Disposables.create()
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    emitter.onError(error)
                    return
                }
                guard let data = data,
                      let image = UIImage(data: data) else {
                    emitter.onNext(nil)
                    emitter.onCompleted()
                    return
                }
                emitter.onNext(image)
                emitter.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}
