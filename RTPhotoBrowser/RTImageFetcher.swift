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
    var taskDict:[RTPhotoModel : RetrieveImageTask] = [:];
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
        }, completionHandler: { (image, error, type, url) in
            self.taskDict.removeValue(forKey: photo);
            
            guard let image = image else {
                if let delegate = self.delegate {
                    if delegate.responds(to: #selector(RTImageFetchDelegate.imageDidFailLoad(error:photoModel:))) {
                        delegate.imageDidFailLoad(error: error, photoModel: photo);
                    }
                }
                return;
            }
            
            if let delegate = self.delegate {
                if delegate.responds(to: #selector(RTImageFetchDelegate.imageDidLoaded(image:photoModel:))) {
                    delegate.imageDidLoaded(image: image, photoModel: photo);
                }
            }
        });
    }
    
    func fetchCacheImage(withUrl urlString: String?) -> UIImage? {
        guard let urlString = urlString else {
            return nil
        }
        
        guard let url = URL(string: urlString) else {
            return nil;
        }
        
        var cacheImage: UIImage?
        let result = KingfisherManager.shared.cache.isImageCached(forKey: url.cacheKey)
        if result.cached, let cacheType = result.cacheType {
            switch cacheType {
            case .memory:
                cacheImage = KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: url.cacheKey)
            case .disk:
                cacheImage = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: url.cacheKey)
            default:
                cacheImage = nil
            }
        }
        
        return cacheImage;
    }
    
}
