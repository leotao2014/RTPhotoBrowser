//
//  RTPhotoBrowserConfig.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/5/30.
//  Copyright © 2017年 leotao. All rights reserved.
//

import Foundation
import UIKit

class RTPhotoBrowserConfig {
    static let defaulConfig = RTPhotoBrowserConfig();
    
    var placeHolderImage = UIImage(named: "rt-placeholder");
    var loadFailImage = UIImage(named: "rt-fail");
    var footerHeight:CGFloat = 49.0;
    var headerHeight:CGFloat = 64.0;
    var shouldSupportRotate = true;
}
