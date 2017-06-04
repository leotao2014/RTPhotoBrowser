//
//  RTPhotoModel.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/2/26.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

enum RTImageDownloadPriority {
    case high
    case low
    case cancel
}
class RTPhotoModel: NSObject {
    var picUrl:String = "";     // 图片地址
    var originalPicUrl:String?
    
    var downloadPriority = RTImageDownloadPriority.high
    var index:Int = 0;
    var viewOriginalPic:Bool {
        get {
            guard let ogUrl = originalPicUrl else { return false }
            let cacheKey = UserDefaults.standard.object(forKey: ogUrl);
            return cacheKey != nil;
        }
        
        set {
            if let url = originalPicUrl {
                if newValue {
                    UserDefaults.standard.set("true", forKey: url);
                } else {
                    UserDefaults.standard.removeObject(forKey: url);
                }
            }
        }
    }
    
    init(picUrls: (picUrl:String, originalPicUrl:String?)) {
        super.init();
        
        picUrl = picUrls.picUrl;
        originalPicUrl = picUrls.originalPicUrl;
    }
}
