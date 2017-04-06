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
    var photos = [RTPhotoModel]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        ImageCache.default.clearMemoryCache();
        
    }
    
    func setup() {
        let layout = UICollectionViewFlowLayout();
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout);
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
        
        
        for url in urls {
            let model = RTPhotoModel();
            model.bigPicURL = url;
            photos.append(model);
        }
        
    }
    
    deinit {
        print("dealloc - PhotoSelectVC");
    }
    
//    func dismissAction() {
//        ImageCache.default.clearMemoryCache();
//        self.dismiss(animated: true, completion: nil);
//    }
}

extension PhotoSelectVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = RTPhotoBrowser();
        browser.delegate = self;
        
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
    
    func photoForIndex(index: Int) -> RTPhotoModel {
        return self.photos[index];
    }
}

//extension PhotoSelectVC: GSPhotoBrowserDelegate {
//    func numberOfPhotos() -> Int {
//        return self.photos.count;
//    }
//    
//    func photoForIndex(index:Int) -> GSPhoto {
//        return self.photos[index];
//    }
//    
//    func sourceImageViewFrameForIndex(index: Int) -> CGRect {
//        let photo = self.photos[index];
//        return photo.sourceFrame;
//    }
//}
