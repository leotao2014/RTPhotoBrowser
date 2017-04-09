//
//  RTImagePage.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/3/13.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

class RTImagePage: UIScrollView {
    var indexLabel:UILabel = {
        let label = UILabel();
        label.font = UIFont.systemFont(ofSize: 70);
        label.textColor = UIColor.white;
        label.textAlignment = .center;
        
        return label;
    }();
    
    var pageIndex:Int = 0 {
        didSet {
            indexLabel.text = String(pageIndex);
        }
    }
    
    var photo:RTPhotoModel? {
        didSet {
            if let photo = photo {
                RTImageFetcher.fetcher.fetchImage(photo: photo);
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        addSubview(indexLabel);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        indexLabel.frame = self.bounds;
    }
    
    func setImage(image: UIImage) {
        print(#function);
    }
    
    func imageFailLoad(error:Error?) {
        print(#function);
    }
    
    func updateImageLoadProgress(progress:CGFloat) {
        print("updateImageLoadProgress\(progress)");
    }
}
