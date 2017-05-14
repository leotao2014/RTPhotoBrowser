//
//  RTPresentationController.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/5/14.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

class RTPresentationController: UIPresentationController {
    var viewNeedHidden:UIView?
    
    var maskView:UIView = {
        let view = UIView();
        view.backgroundColor = UIColor.black;
        
        return view;
    }();
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin();
        
        guard let containerView = self.containerView else { return }
        viewNeedHidden?.isHidden = true;
        containerView.addSubview(maskView);
        maskView.frame = containerView.bounds;
        maskView.alpha = 0.0;
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.maskView.alpha = 1.0;
        }, completion: nil);
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin();
        
        viewNeedHidden?.isHidden = true;
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) in
            self.maskView.alpha = 0.0;
        }, completion: { (_) in
            self.viewNeedHidden?.isHidden = false;
        })
    }
}
