//
//  PhotoSelectVC.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/2/26.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoSelectVC: UIViewController {
    var photos = [PhotoModel]();
    var collectionView:UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup();
    }
    
    func setup() {
        let layout = UICollectionViewFlowLayout();
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout);
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "image");
        self.view.addSubview(collectionView);
        collectionView.backgroundColor = UIColor.white;
        
        let urls = ["http://images-10038599.cos.myqcloud.com/1.jpg",
                    "http://images-10038599.cos.myqcloud.com/2.jpg",
                    "http://images-10038599.cos.myqcloud.com/3.jpg",
                    "http://images-10038599.cos.myqcloud.com/4.jpg",
                    "http://images-10038599.cos.myqcloud.com/5.jpg",
                    "http://images-10038599.cos.myqcloud.com/6.jpg",
                    "http://images-10038599.cos.myqcloud.com/7.jpg",
                    "http://images-10038599.cos.myqcloud.com/8.jpg",
                    "http://images-10038599.cos.myqcloud.com/9.jpg",
                    "http://images-10038599.cos.myqcloud.com/10.jpg",
                    "http://images-10038599.cos.myqcloud.com/11.jpg",
                    "http://images-10038599.cos.myqcloud.com/QQ20161015-0.png",
                    "http://images-10038599.cos.myqcloud.com/QQ20161015-1.png"];
        
        
        photos = urls.map { (url) -> PhotoModel in
            let model = PhotoModel();
            model.bigPicURL = url;
            return model;
        }
    }
    
    deinit {
        ImageCache.default.clearMemoryCache();
        print("dealloc - PhotoSelectVC");
    }
}

extension PhotoSelectVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = RTPhotoBrowser();
        browser.delegate = self;
        browser.currentIndex = indexPath.item;
        self.modalPresentationStyle = .custom;
        self.present(browser, animated: true, completion: nil);
    }
}

extension PhotoSelectVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! ImageCell;
        let photo = self.photos[indexPath.item];
        cell.imageUrl = photo.bigPicURL!;
        
        return cell;
    }
}



let margin:CGFloat = 10.0;
extension PhotoSelectVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let col = 3;
        let width = (UIScreen.main.bounds.width - margin * (CGFloat(col) + 1.0)) / CGFloat(col);
        let size = CGSize(width: width, height: width);
        
        return size;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 0, 10);
    }
}

extension PhotoSelectVC: RTPhotoBrowserDelegate {    
    func numberOfPhotosForBrowser() -> Int {
        return self.photos.count;
    }
    
    
    func photoForIndex(index: Int) -> RTPhotoModelDelegate {
        return self.photos[index];
    }
    
    func sourceImageViewForIndex(index: Int) -> UIImageView? {
        let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as! ImageCell;
        return cell.imageView;
    }
}
