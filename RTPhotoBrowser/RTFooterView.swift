//
//  RTFooterView.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/5/30.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

class RTFooterView: UIView {
    let btn = UIButton();
    
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
    
    var displayOriginalPicClosure: ((Void) -> Void)?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.backgroundColor = UIColor.clear;
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15);
        btn.setTitle("原图", for: .normal);
        btn.setTitleColor(.white, for: .normal);
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = UIColor.lightGray.cgColor;
        btn.layer.cornerRadius = 5.0;
        btn.addTarget(self, action: #selector(showOriginalPic), for: .touchUpInside);        
        
        self.addSubview(shadeView);
        self.addSubview(btn);
        self.addSubview(contentLabel);
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        shadeView.frame = self.bounds;
        
        let marginLeft:CGFloat = 10;
        let marginTop: CGFloat = 10;
        let marginBottom:CGFloat = 10;
        let marginRight:CGFloat = 10;
        
        var size = btn.sizeThatFits(bounds.size);
        size.width += 10;
        size.height += 5;
        btn.frame = CGRect(x: marginLeft, y: bounds.height - size.height - marginBottom, width: size.width, height: size.height);
        
        var textSize = contentLabel.sizeThatFits(CGSize(width: bounds.width - marginLeft - marginRight, height: CGFloat(MAXFLOAT)));
        let textMaxHeight = self.bounds.height - marginTop - marginBottom * 2.0 - btn.frame.height;
        textSize.height = min(textSize.height, textMaxHeight);
        contentLabel.frame = CGRect(x: marginLeft, y: marginTop, width: textSize.width, height: textSize.height);
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showOriginalPic() {
        if let closure = displayOriginalPicClosure {
            closure();
        }
    }
}
