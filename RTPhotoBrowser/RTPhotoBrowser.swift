//
//  RTPhotoBrowser.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/3/13.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

@objc protocol RTPhotoBrowserDelegate: NSObjectProtocol {
    func numberOfPhotosForBrowser() -> Int;
    func photoForIndex(index: Int) -> RTPhotoModel;
    @objc optional func sourceImageViewForIndex(index: Int) -> UIImageView?
}

enum RTPhotoBrowserShowStyle {
    case normal;
    case weibo;
}

class RTPhotoBrowser: UIViewController {
    var showStyle: RTPhotoBrowserShowStyle = .weibo;
    var visiblePages:Set<RTImagePage> = Set();
    var recyclePages:Set<RTImagePage> = Set();
    
    var container: UIScrollView = {
        let scrollView = UIScrollView();
        scrollView.isPagingEnabled = true;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false;
        print(self);
        
        return scrollView;
    }();

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension RTPhotoBrowser: UIScrollViewDelegate {
    
}
