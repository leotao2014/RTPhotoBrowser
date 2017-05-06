//
//  ModalAnimator.swift
//  PtBrowser
//
//  Created by leotao on 16/10/12.
//  Copyright © 2016年 leotao. All rights reserved.
//

import UIKit

class ModalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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
        
        if present {
            toVC!.view.backgroundColor = UIColor.black.withAlphaComponent(0);
            let browser = toVC! as! RTPhotoBrowser;
            transitionContext.containerView.addSubview(toVC!.view);
            
            browser.beginPresentAnimation(withCompletionHandler: { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled);
            });
        } else {
            let browser = fromVC! as! RTPhotoBrowser;
            transitionContext.containerView.insertSubview(toVC!.view, at: 0);
            browser.beginDismissAnimation(withCompletionHandler: { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled);
            });
        }
    }
}
