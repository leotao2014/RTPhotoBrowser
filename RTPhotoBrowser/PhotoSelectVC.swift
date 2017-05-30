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
        

        
        let urls = ["http://7xr16i.com1.z0.glb.clouddn.com/607210ee51151af6f9a25a1c75f55aab_copy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/6ee28dfeeff39ed9807b868c9969d8fb_copy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/8c2cfc7c0e713b9c3bf02daec77e2cbe_copy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/83f79630ae87d6ddfa1d6adb4413ff70_copy.jpg",
                    "http://images-10038599.cos.myqcloud.com/5.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/a622abd5a0fbc15337d2848fc58eae1a_copy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/landscapecopy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/924a4008418cfe474363545cfc444051_copy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/9_copy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/351b86227b5714f60278a4c501346cd4_copy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/11_copy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/98c7d2dfe77926ecbb590ebb99ff33c3_copy.jpg",
                    "http://7xr16i.com1.z0.glb.clouddn.com/ab062e4df53eede0176035bc8221acec_copy.jpg",
                    ];
        
        let highQualityUrls = ["http://images-10038599.cos.myqcloud.com/1.jpg",
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
            model.picUrl = url;
            return model;
        }
        
        photos = photos.enumerated().map({ (index, model) -> PhotoModel in
            model.highQualityUrl = highQualityUrls[index];
            
            return model;
        })
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default;
    }
    
    deinit {
        ImageCache.default.clearMemoryCache();
        print("dealloc - PhotoSelectVC");
    }
}

extension PhotoSelectVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _ = RTPhotoBrowser.show(initialIndex: indexPath.item, delegate: self, prsentedVC: self);
    }
}

extension PhotoSelectVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! ImageCell;
        let photo = self.photos[indexPath.item];
        cell.imageUrl = photo.picUrl;
        
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
    func rt_numberOfPhotosForBrowser(browser: RTPhotoBrowser) -> Int {
        return self.photos.count;
    }
    
    func rt_picUrlsForIndex(index: Int, browser: RTPhotoBrowser) -> (picUrl: String, originalPicUrl: String?) {
        let photo = self.photos[index];
        return (photo.picUrl, photo.highQualityUrl);
    }
    
    func rt_thumnailView(atIndex index: Int, browser: RTPhotoBrowser) -> UIView? {
        let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ImageCell;
        return cell?.imageView;
    }
    
    func rt_previewImage(atIndex index: Int, browser: RTPhotoBrowser) -> UIImage? {
        let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ImageCell;
        return cell?.imageView.image;
    }
    
    func rt_heightForFooterView(atIndex index: Int, browser: RTPhotoBrowser) -> CGFloat {
        if index % 2 == 0 {
            return 88;
        } else {
            return 150;
        }
    }
}
