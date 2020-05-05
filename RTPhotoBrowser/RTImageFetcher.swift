//
//  GSImageFetcher.swift
//  PtBrowser
//
//  Created by leotao on 16/10/30.
//  Copyright © 2016年 leotao. All rights reserved.
//

import UIKit
import Kingfisher

let GSPHOTO_PROGRESS_NOTIFICATION = "GSPHOTO_PROGRESS_NOTIFICATION";
let GSPHOTO_IMAGE_LOADED_NOTIFICATION = "GSPHOTO_IMAGE_LOADED_NOTIFICATION";

@objc protocol RTImageFetchDelegate: NSObjectProtocol {
    func imageDidLoaded(image: UIImage,  photoModel:RTPhotoModel);
    func imageDidFailLoad(error:Error?, photoModel:RTPhotoModel);
    func imageLoadingUpdateProgress(progress: CGFloat, photoModel:RTPhotoModel);
}

class RTImageFetcher: NSObject {
    static let fetcher = RTImageFetcher();
    var taskDict:[RTPhotoModel : DownloadTask] = [:];
    weak var delegate:RTImageFetchDelegate?
    
    func fetchImage(photo:RTPhotoModel) {
        var downloadUrlString:String;
        
        if photo.viewOriginalPic {
            downloadUrlString = photo.originalPicUrl!;
        } else {
            downloadUrlString = photo.picUrl;
        }
        
        guard let url = URL(string: downloadUrlString) else { return  };
        
        if url.scheme?.lowercased() == "assets-library" {   // 相册图片
            fetchImageFromSandBox(photo: photo, url: url);
        } else if url.isFileURL {   // 沙盒图片
            fetchImageFromSandBox(photo: photo, url: url);
        } else {    // 网络图片
            fetchImageFromNetwork(photo: photo, url: url);
        }
    }
    
    func fetchImageFromAssetsLibrary(photo:RTPhotoModel, url:URL) {
        
    }
    
    func fetchImageFromSandBox(photo:RTPhotoModel, url:URL) {
        
    }
    
    func fetchImageFromNetwork(photo:RTPhotoModel, url:URL) {
        KingfisherManager.shared.retrieveImage(with: url, options: [.backgroundDecode], progressBlock: { (received, total) in
            let progress = CGFloat(received) / CGFloat(total);
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(RTImageFetchDelegate.imageLoadingUpdateProgress(progress:photoModel:))) {
                    delegate.imageLoadingUpdateProgress(progress: progress, photoModel: photo);
                }
            }
        }) { (result) in
            self.taskDict.removeValue(forKey: photo);
            switch result {
            case .success(let r):
                if let delegate = self.delegate {
                    if delegate.responds(to: #selector(RTImageFetchDelegate.imageDidLoaded(image:photoModel:))) {
                        delegate.imageDidLoaded(image: r.image, photoModel: photo);
                    }
                }
            case .failure(let err):
                if let delegate = self.delegate {
                    if delegate.responds(to: #selector(RTImageFetchDelegate.imageDidFailLoad(error:photoModel:))) {
                        delegate.imageDidFailLoad(error: err, photoModel: photo);
                    }
                }
            }
        }
    }
    
    func fetchCacheImage(withUrl urlString: String?, completion: @escaping (UIImage?) -> (Void)) {
        guard let urlString = urlString else {
            completion(nil)
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        KingfisherManager.shared.cache.retrieveImage(forKey: url.cacheKey) { (result) in
            switch result {
            case .success(let r):
                completion(r.image)
            default:
                completion(nil)
            }
        }
    }
    
    func clearMemoryCache() {
        ImageCache.default.clearMemoryCache();
    }
    
}
