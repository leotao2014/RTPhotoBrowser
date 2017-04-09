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
        guard let urlString = photo.bigPicURL else {
            print("图片地址为空");
            return
        };
        
        guard let url = URL(string:urlString) else {
            return
        };
        
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
        var tasksNeedMove = [RTPhotoModel]();
        // 清空所有不需要下载的任务
        self.taskDict.forEach { (model, task) in
            if model.downloadPriority == .cancel {
                task.cancel();
                tasksNeedMove.append(model);
            }
        }
        
        tasksNeedMove.forEach { (model) in
            self.taskDict.removeValue(forKey: model);
        }
        
        // 查看任务是否已存在。存在说明还没下完则直接返回
        var task = self.taskDict[photo];
        if task != nil {    // 已经处于正在下载的状态了则直接return
            return;
        } else {
            // 此处一定要设置后台解码图片。否则加载大图片时会卡顿
            task = KingfisherManager.shared.retrieveImage(with: url, options: [.backgroundDecode], progressBlock: { (received, total) in
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
            
            if let task = task {
                self.taskDict[photo] = task;
            }
        }
    }
    
}
