//
//  RTProgressView.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/5/7.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

let kProgressViewWidth:CGFloat = 60;

class RTProgressView: UIView {
    var progress:CGFloat = 0.0 {
        didSet {
            setupLayer(withProgress: progress);
        }
    }
    
    var backgroundLayer = { () -> CAShapeLayer in
        let layer = CAShapeLayer();
        layer.strokeColor = UIColor.white.cgColor;
        layer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor;
        return layer;
    }();
    
    var progressLayer = { () -> CAShapeLayer in
        let layer = CAShapeLayer();
        layer.strokeColor = UIColor.clear.cgColor;
        layer.fillColor = UIColor.white.cgColor;
        return layer;
    }();
    
    init() {
        super.init(frame: .zero);
        
        self.layer.addSublayer(backgroundLayer);
        self.layer.addSublayer(progressLayer);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        backgroundLayer.frame = self.bounds;
        progressLayer.frame = self.bounds;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayer(withProgress progress:CGFloat) {
        if self.bounds.size == .zero {
            return;
        }
        
        let bgPath = UIBezierPath();
        let center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5);
        let radius = self.bounds.width * 0.5;
        bgPath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(.pi * 2.0), clockwise: true);
        backgroundLayer.path = bgPath.cgPath;
        
        let progressPath = UIBezierPath();
        let progressRadius = radius - 2.5;
        progressPath.move(to: center);
        progressPath.addArc(withCenter: center, radius: progressRadius, startAngle: -(.pi / 2.0), endAngle: (2.0 * progress - 0.5) * .pi, clockwise: true);
        progressLayer.path = progressPath.cgPath;
    }
}
