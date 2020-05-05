//
//  ImageCell.swift
//  PtBrowser
//
//  Created by leotao on 2017/2/14.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit
import Kingfisher

class ImageCell: UICollectionViewCell {
    let imageView = UIImageView();
    var imageUrl:String = "" {
        didSet {
            imageView.kf.setImage(with: URL(string:imageUrl))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.contentView.addSubview(imageView);
        self.contentView.backgroundColor = UIColor(red: 92 / 255.0, green: 105 / 255.0, blue: 111 / 255.0, alpha: 1.0);
        imageView.clipsToBounds = true;
        imageView.contentMode = .scaleAspectFill;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        imageView.frame = self.contentView.bounds;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
