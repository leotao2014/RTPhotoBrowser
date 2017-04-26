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

protocol RTPhotoModelDelegate: NSObjectProtocol {
    var thumbPicURL:String? {get set};
    var bigPicURL:String? {get set};
}

class RTPhotoModel: NSObject {
    var thumbPicURL:String?     // 缩略图地址
    var bigPicURL:String?       // 大图或原图地址
    
    var downloadPriority = RTImageDownloadPriority.high
    var index:Int = 0;
    
    init(model:RTPhotoModelDelegate) {
        self.thumbPicURL = model.thumbPicURL;
        self.bigPicURL = model.bigPicURL;
    }
}
