//
//  ViewController.swift
//  KakaoImageSearch
//
//  Created by jc.kim on 3/4/21.
//

import UIKit
import RxSwift
import RxCocoa

class SearchImageViewController: UIViewController {
    
    @IBOutlet weak var listCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let searchImageItems: BehaviorRelay<[Document]> = BehaviorRelay(value: [])
    var disposeBag = DisposeBag()
    
    
    private func setupBindings() {
        searchImageItems
            .bind(to: listCollectionView.rx.items(cellIdentifier: ImageCollectionViewCell.identifier,
                                                  cellType: ImageCollectionViewCell.self)) { index, item, cell in
                cell.setData(item)
            }
            .disposed(by: disposeBag)
        
        
        searchBar.rx.text.orEmpty
            .debounce(.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext:fetchMenuItems)
            .disposed(by: disposeBag)
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.rx.controlEvent(.valueChanged)
            .map{self.searchBar.text ?? ""}
            .subscribe(onNext: fetchMenuItems)
            .disposed(by: disposeBag)
        listCollectionView.refreshControl = refreshControl
    }
    
    private func configureUI() {
        searchBar.autocapitalizationType = .none
        
        listCollectionView.dataSource = nil
        listCollectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        listCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMenuItems()
        setupBindings()
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
    
    func fetchMenuItems(_ query: String = "") {
        
        APIService.searchImageRx(query, 1)
            .observe(on: MainScheduler.instance)
            .do(onError: { [weak self] error in
                //                self?.showAlert("Fetch Fail", error.localizedDescription)
            }, onDispose: { [weak self] in
                //                self?.activityIndicator.isHidden = true
                //                Thread.sleep(forTimeInterval: 1)
                self?.listCollectionView.refreshControl?.endRefreshing()
            })
            .asDriver(onErrorJustReturn: [])
            .drive(searchImageItems)
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "aaa",
           let detailVC = segue.destination as? DetailViewController {
            
            if let tuple = sender as? (UIImage?, IndexPath) {
                let items = searchImageItems.value
                detailVC.detailImageItems.accept((tuple.0, items[tuple.1.row]))
            }
        }
    }
}


extension SearchImageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell
        performSegue(withIdentifier: "aaa", sender: (cell?.searchImageView.image , indexPath))
    }
    
}


extension SearchImageViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        var bounds = collectionView.bounds
        bounds.size.height += bounds.origin.y
        
        var width = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
        var height = bounds.height - (layout.sectionInset.top + layout.sectionInset.bottom)
        
        width = (width - (layout.minimumInteritemSpacing * 2 )) / 3
        height = width
        
        return CGSize(width: width.rounded(.down), height: height.rounded(.down))
    }
    
}
