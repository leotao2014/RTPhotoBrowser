//
//  RTNavigationController.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/5/30.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

class RTNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        
        if let topVC = topViewController {
            if let presentVC = topVC.presentedViewController {
                return presentVC.preferredStatusBarStyle;
            }
            
            return topVC.preferredStatusBarStyle;
        }
        
        return .default;
    }
}
