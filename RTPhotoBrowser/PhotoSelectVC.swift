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
        

        
        let urls: [Dictionary<String, String>] = [
            [
                "thumbnail": "https://wx3.sinaimg.cn/orj360/a17004b2gy1gehlhsjj61j20u01hc120.jp",
                "large": "https://photo.weibo.com/2708473010/wbphotos/large/mid/4501241004504614/pid/a17004b2gy1gehlhsjj61j20u01hc120"],
            [
            "thumbnail": "https://wx3.sinaimg.cn/mw690/bc52b9dfly1gehbgbfdhwj20j60qvq8j.jpg",
            "large": "https://wx3.sinaimg.cn/large/bc52b9dfly1gehbgbfdhwj20j60qvq8j.jpg"],
            [
            "thumbnail": "https://wx2.sinaimg.cn/mw690/bc52b9dfly1gehbgbz3ptj20j60sswl2.jpg",
            "large": "https://wx2.sinaimg.cn/large/bc52b9dfly1gehbgbz3ptj20j60sswl2.jpg"],
            [
            "thumbnail": "https://wx4.sinaimg.cn/mw690/bc52b9dfly1gehbgd5xsoj20j60rmq9v.jpg",
            "large": "https://wx4.sinaimg.cn/large/bc52b9dfly1gehbgd5xsoj20j60rmq9v.jpg"],
            [
            "thumbnail": "https://wx3.sinaimg.cn/mw690/bc52b9dfly1gehbgdubwsj20j60tdn3r.jpg",
            "large": "https://wx3.sinaimg.cn/large/bc52b9dfly1gehbgdubwsj20j60tdn3r.jpg"],
            [
            "thumbnail": "https://wx4.sinaimg.cn/mw690/bc52b9dfly1gehbgetb6nj20j60s6gsg.jpg",
            "large": "https://wx4.sinaimg.cn/large/bc52b9dfly1gehbgetb6nj20j60s6gsg.jpg"],
            [
            "thumbnail": "https://wx3.sinaimg.cn/mw690/bc52b9dfly1gehbgftkfhj20j60srq5x.jpg",
            "large": "https://wx3.sinaimg.cn/large/bc52b9dfly1gehbgftkfhj20j60srq5x.jpg"],
            [
            "thumbnail": "https://wx4.sinaimg.cn/mw690/bc52b9dfly1gegps3uujgj20rs0rs0u7.jpg",
            "large": "https://wx4.sinaimg.cn/large/bc52b9dfly1gegps3uujgj20rs0rs0u7.jpg"],
            [
            "thumbnail": "https://wx1.sinaimg.cn/mw690/94d9c01fly1gehgoot8uaj20h808maan.jpg",
            "large": "https://wx1.sinaimg.cn/mw1024/94d9c01fly1gehgoot8uaj20h808maan.jpg"]
        ];

        photos = urls.map({ (dict) -> PhotoModel in
            let model = PhotoModel()
            model.picUrl = dict["thumbnail", default: ""]
            model.highQualityUrl = dict["large", default: ""]
            
            return model
        })
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.collectionView.frame = self.view.bounds;
        self.collectionView.reloadData();
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
    
        let size = CGSize(width: floor(width) , height: floor(width));
        
        return size;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 10, left: 10, bottom: 0, right: 10);
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
