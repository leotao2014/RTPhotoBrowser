//
//  ModalAnimator.swift
//  PtBrowser
//
//  Created by leotao on 16/10/12.
//  Copyright © 2016年 leotao. All rights reserved.
//

import UIKit

class ModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var startView:UIView?   // 只是用来计算最开始的frame
    var finalView:UIView?   // 只是用来计算最终的frame
    var scaleView:UIView?   // 最终用来缩放的动画View 
    
    
    var present = true;
    var duration:TimeInterval {
        return present ? 0.25 : 0.20;
    };
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration;
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from);
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to);
        
        let fromView = transitionContext.view(forKey: .from);
        let toView = transitionContext.view(forKey: .to);
        
        let isPresent = toVC?.presentingViewController == fromVC;
        let containerView = transitionContext.containerView;
        
        guard let startView = self.startView, let finalView = self.finalView, let scaleView = self.scaleView else { return  };
        
        guard let startFrame = startView.superview?.convert(startView.frame, to: containerView) else { return };
        let relativeFrame = finalView.convert(finalView.bounds, to: nil);
        let windowBounds = UIScreen.main.bounds;
        
        var endFrame = startFrame;
        var endAlpha:CGFloat = 0.0;
    
        if windowBounds.intersects(relativeFrame) { // 在屏幕内的
            endAlpha = 1.0;
            endFrame = finalView.convert(finalView.bounds, to: containerView);
        }
        
        print("startFrame =\(startFrame), endFrame = \(endFrame)");
        scaleView.frame = startFrame;
        containerView.addSubview(scaleView);
        
        if !isPresent { // 如果是dismiss动画则隐藏fromView
            fromView?.isHidden = true;
        }
        
        UIView.animate(withDuration: duration, animations: {
            scaleView.alpha = endAlpha;
            scaleView.frame = endFrame;
        }) { (_) in
            if (isPresent) {    // 如果是present的话需要将toView在结束的时候添加上去
                containerView.addSubview(toView!);
            }
            
            scaleView.removeFromSuperview();
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled);
        }
    }
}
