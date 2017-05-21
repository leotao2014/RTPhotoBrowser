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
    var picUrl:String {get set};
    var highQualityUrl:String? {get set};
}

class RTPhotoModel: NSObject {
    var picUrl:String     // 图片地址
    var originalPicUrl:String?
    
    var downloadPriority = RTImageDownloadPriority.high
    var index:Int = 0;
    
    init(model:RTPhotoModelDelegate) {
        self.picUrl = model.picUrl;
        self.originalPicUrl = model.highQualityUrl;
    }
}
