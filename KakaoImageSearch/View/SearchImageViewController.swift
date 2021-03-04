//
//  ViewController.swift
//  KakaoImageSearch
//
//  Created by jc.kim on 3/4/21.
//

import UIKit


class Landscape {
   let urlString: String
   var url: URL {
      guard let url = URL(string: urlString) else {
         fatalError("invalid URL")
      }
      return url
   }
   var image: UIImage?
   
   init(urlString: String) {
      self.urlString = urlString
   }
   
   static func generateData() -> [Landscape] {
      return (1...36).map { Landscape(urlString: "https://kxcodingblob.blob.core.windows.net/mastering-ios/\($0).jpg") }
   }
}




class SearchImageViewController: UIViewController {
    
    @IBOutlet weak var listCollectionView: UICollectionView!
    
    lazy var refreshControl: UIRefreshControl = { [weak self] in
        let control = UIRefreshControl()
        control.tintColor = self?.view.tintColor
        return control
    }()
    
    @objc func refresh() {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.list = Landscape.generateData()
            strongSelf.downloadTasks.forEach { $0.cancel() }
            strongSelf.downloadTasks.removeAll()
            Thread.sleep(forTimeInterval: 0.5)
            
            DispatchQueue.main.async {
                strongSelf.listCollectionView.reloadData()
                strongSelf.listCollectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    var list = Landscape.generateData()
    var downloadTasks = [URLSessionTask]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listCollectionView.prefetchDataSource = self
        
        listCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
    }
}

extension SearchImageViewController: UICollectionViewDataSourcePrefetching {
    
 
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            downloadImage(at: indexPath.item)
        }
        print(#function, indexPaths)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print(#function, indexPaths)
        for indexPath in indexPaths {
            cancelDownload(at: indexPath.item)
        }
    }
}



extension SearchImageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        if let imageView = cell.viewWithTag(100) as? UIImageView {
            if let image = list[indexPath.row].image {
                imageView.image = image
            } else {
                imageView.image = nil
                downloadImage(at: indexPath.row)
            }
        }
        
        return cell
    }
}


extension SearchImageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let imageView = cell.viewWithTag(100) as? UIImageView {
            if let image = list[indexPath.row].image {
                imageView.image = image
            } else {
                imageView.image = nil
            }
        }
        
    }
}


extension SearchImageViewController {
    func downloadImage(at index: Int) {
        //다운로드한 이미지가 있는지 확인. 이미지가 있다면 다운로드 메소드를 실행할 필요가 없다.
        guard list[index].image == nil else {
            return
        }
        
        //동일한 이미지를 다운로드하고 있는지 확인하고 중복다운로드를 방지한다.
        let targetUrl = list[index].url
        guard !downloadTasks.contains(where: { $0.originalRequest?.url == targetUrl }) else {
            return
        }
        
        print(#function, index)
        
        let task = URLSession.shared.dataTask(with: targetUrl) { [weak self] (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let data = data, let image = UIImage(data: data), let strongSelf = self {
                strongSelf.list[index].image = image
                let reloadTargetIndexPath = IndexPath(row: index, section: 0)
                DispatchQueue.main.async {
                    
                    if strongSelf.listCollectionView.indexPathsForVisibleItems.contains(reloadTargetIndexPath) == .some(true) {
                        strongSelf.listCollectionView.reloadItems(at: [reloadTargetIndexPath])
                    }
                }
                
                strongSelf.completeTask()
            }
        }
        task.resume()
        downloadTasks.append(task)
    }
    
    func completeTask() {
        downloadTasks = downloadTasks.filter { $0.state != .completed }
    }
    
    func cancelDownload(at index: Int) {
        let targetUrl = list[index].url
        guard let taskIndex = downloadTasks.firstIndex(where: { $0.originalRequest?.url == targetUrl }) else {
            return
        }
        let task = downloadTasks[taskIndex]
        task.cancel()
        downloadTasks.remove(at: taskIndex)
    }
}




extension SearchImageViewController: UICollectionViewDelegateFlowLayout {
 
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    print(indexPath.section, "#1", #function)
    guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
    
    var bounds = collectionView.bounds
    bounds.size.height += bounds.origin.y
    
    
    
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    
    
    
    //컬렉션뷰에서 섹션인셋을 빼면 셀을 표시할 수 있는 최대 크기를 얻을 수 있다.
    var width = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
    var height = bounds.height - (layout.sectionInset.top + layout.sectionInset.bottom)
    
    
    
    //스크롤 방향에 따라서 최종 너비와 높이를 계산
    switch layout.scrollDirection {
    case .vertical:
      
        width = (width - (layout.minimumInteritemSpacing * 2 )) / 3
        height = width
    case .horizontal:
      width = (width - (layout.minimumLineSpacing * 2 )) / 3
        
      if indexPath.item > 0 {
        height = (height - (layout.minimumInteritemSpacing * 4)) / 5
      }
    }
    
    return CGSize(width: width.rounded(.down), height: height.rounded(.down))
  }
  
}

