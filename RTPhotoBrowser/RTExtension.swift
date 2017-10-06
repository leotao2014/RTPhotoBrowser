//
//  RTExtension.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/5/30.
//  Copyright © 2017年 leotao. All rights reserved.
//

import Foundation
import UIKit

enum RTPhotoBrowserShowStyle {
    case normal;
    case weibo;
    case twitter;
}

let gap:CGFloat = 5.0;

extension Int {
    var rtFloatValue:CGFloat {
        return CGFloat(self);
    }
}

extension UInt32 {
    var rtFloatValue:CGFloat {
        return CGFloat(self);
    }
}

extension CGFloat {
    var rtIntValue:Int {
        return Int(self);
    }
}

extension UIColor {
    class func rgba(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha);
    }
    
    class func rgb(red:CGFloat, green:CGFloat, blue:CGFloat) -> UIColor {
        return UIColor.rgba(red: red, green: green, blue: blue, alpha: 1.0);
    }
    
    class func randomColor() -> UIColor {
        let red = arc4random_uniform(255).rtFloatValue / 255.0;
        let green = arc4random_uniform(255).rtFloatValue / 255.0;
        let blue = arc4random_uniform(255).rtFloatValue / 255.0;
        return UIColor.rgb(red: red, green: green, blue: blue);
    }
}

extension UIImage {
    func rt_calculateImageViewframe(givenBounds:CGRect, deviceOrientation:UIInterfaceOrientation) -> CGRect {
        print("deviceOrientation =\(deviceOrientation.rawValue)");
        var x:CGFloat = 0;
        var size:CGSize = .zero;
        if self.size.width < givenBounds.size.width && self.size.height < givenBounds.size.height {
            size = self.size;
            x = (givenBounds.size.width - size.width) * 0.5;
        } else {
            let heightScale = self.size.height / givenBounds.height;
            let widthScale = self.size.width / givenBounds.width;
            let scale = self.size.height / self.size.width;
            
             if deviceOrientation.isLandscape { // 横屏处理
                let screenScale:CGFloat = UIScreen.main.bounds.width / UIScreen.main.bounds.height;
                let imageScale = self.size.width / self.size.height;
                
                if imageScale > screenScale {
                    size.width = givenBounds.size.width;
                    size.height = size.width * (self.size.height / self.size.width);
                } else {
                    size.height = givenBounds.size.height;
                    size.width = size.height * (self.size.width / self.size.height);
                    x = (givenBounds.size.width - size.width) * 0.5;
                }
             } else {   // 当做竖屏处理
                if heightScale > 1.0 && heightScale <= 1.51 && widthScale <= 1.1 {   // 虽然此时图片高度大于屏幕高度，但是高的不明显(倍数不超过1.51.根据qq中的相册反复试验得出)。所以不看成长图
                    size.height = givenBounds.size.height;
                    size.width = size.height / scale;
                    x = (givenBounds.size.width - size.width) * 0.5;
                } else {
                    size.width = givenBounds.size.width;
                    size.height = givenBounds.size.width * scale;
                }
            }
        }
        
        var y:CGFloat = 0;
        if size.height < givenBounds.size.height {
            y = (givenBounds.height - size.height) * 0.5;
        }
        
        let rect = CGRect(x: x, y: y, width: size.width, height: size.height);
        
        return rect;
    }
}


