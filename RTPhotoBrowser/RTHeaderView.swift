//
//  RTHeaderView.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/5/30.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

class RTHeaderView: UIView {
    var shadeView:UIView = {
        let view = UIView();
        view.backgroundColor = UIColor.black;
        view.alpha = 0.8;
        return view;
    }();
    
    var contentLabel:UILabel = {
        let label = UILabel();
        label.textColor = UIColor.white;
        label.numberOfLines = 0;
        label.text = "";
        
        return label;
    }();
    
    var displayOriginalPicClosure: (() -> Void)?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.backgroundColor = UIColor.clear;

        self.addSubview(shadeView);
        self.addSubview(contentLabel);
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        shadeView.frame = self.bounds;
        
        let textSize = contentLabel.sizeThatFits(CGSize(width: bounds.width, height: CGFloat(MAXFLOAT)));
        contentLabel.frame = CGRect(x: (bounds.size.width - textSize.width) * 0.5, y: (bounds.size.height - textSize.height) * 0.5, width: textSize.width, height: textSize.height);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
