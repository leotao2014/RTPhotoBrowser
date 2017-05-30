//
//  RTPhotoBrowserDelegate.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/5/30.
//  Copyright © 2017年 leotao. All rights reserved.
//

import Foundation
import UIKit

protocol RTProgressViewDelegate {
    func setProgress(progress:CGFloat);
}

protocol RTPhotoBrowserDelegate : NSObjectProtocol {
    func rt_numberOfPhotosForBrowser(browser:RTPhotoBrowser) -> Int;
    func rt_picUrlsForIndex(index: Int, browser:RTPhotoBrowser) -> (picUrl:String, originalPicUrl:String?);
    // optional
    func rt_thumnailView(atIndex index: Int, browser:RTPhotoBrowser) -> UIView?
    func rt_previewImage(atIndex index:Int, browser:RTPhotoBrowser) -> UIImage?
    func rt_footerViewForBrowser(browser:RTPhotoBrowser) -> UIView?;
    func rt_heightForFooterView(atIndex index:Int, browser:RTPhotoBrowser) -> CGFloat;
    func rt_headerViewForBrowser(browser:RTPhotoBrowser) -> UIView?;
    func rt_heightForHeaderView(atIndex index:Int, browser:RTPhotoBrowser) -> CGFloat;
    func rt_pageDidAppear(atIndex index:Int, browser:RTPhotoBrowser);
    func rt_imageDidLoaded(atIndex index:Int, browser:RTPhotoBrowser);
    func rt_progressViewForBrowser<T:RTProgressViewDelegate>(browser:RTPhotoBrowser) -> T where T:UIView;
}

extension RTPhotoBrowserDelegate {
    func rt_thumnailView(atIndex index: Int, browser:RTPhotoBrowser) -> UIView? {
        return nil;
    }
    
    func rt_previewImage(atIndex index:Int, browser:RTPhotoBrowser) -> UIImage? {
        return nil;
    }
    
    func rt_footerViewForBrowser(browser:RTPhotoBrowser) -> UIView? {
        let footer = RTFooterView(frame: .zero);
        footer.displayOriginalPicClosure = { [weak browser] in
            browser?.setNeedsDisplayOriginalPic();
        };
        
        return footer;
    }
    
    func rt_heightForFooterView(atIndex index:Int, browser:RTPhotoBrowser) -> CGFloat {
        return RTPhotoBrowserConfig.defaulConfig.footerHeight;
    }
    
    
    func rt_headerViewForBrowser(browser:RTPhotoBrowser) -> UIView? {
        let header = RTHeaderView();
        return header;
    }
    
    func rt_heightForHeaderView(atIndex index:Int, browser:RTPhotoBrowser) -> CGFloat {
        return RTPhotoBrowserConfig.defaulConfig.headerHeight;
    }
    
    
    func rt_pageDidAppear(atIndex index:Int, browser:RTPhotoBrowser) {
        let originalImage = browser.originalImage(atIndex: index);
        let existOriginalImage = originalImage != nil;
        
        let contentArray = ["冰与火之歌-提里昂兰尼斯特",
                            "冰与火之歌-囧斯诺",
                            "冰与火之歌-二丫斯塔克",
                            "婚姻起步价戳中多少男人的泪点",
                            "卡哇伊少女",
                            "知乎上的49条神回答，针针见血，看完整个人通透多了",
                            "华大基因楼顶看梧桐山的云",
                            "一位模特",
                            "不知道是啥子东西，壁画?",
                            "健客APP的个人健康报告UI图",
                            "拍的MacBook Air",
                            "qq截图1",
                            "qq截图2"
        ];
        print("第\(index)位上原图是\(existOriginalImage ? "存在" : "不存在")");
        if let footer = browser.browserFooter as? RTFooterView {
            footer.contentLabel.text = contentArray[index];
            footer.btn.isHidden = true;
            footer.btn.isHidden = existOriginalImage;
            footer.setNeedsLayout();
        }
        
        if let header = browser.browserHeader as? RTHeaderView {
            header.contentLabel.text = "\(index + 1)/\(rt_numberOfPhotosForBrowser(browser: browser))";
            header.setNeedsLayout();
        }
    }
    
    func rt_imageDidLoaded(atIndex index:Int, browser:RTPhotoBrowser) {
        let originalImage = browser.originalImage(atIndex: browser.currentVisiblePageIndex);
        let existOriginalImage = originalImage != nil;
        
        print("第\(index)位上原图是\(existOriginalImage ? "存在" : "不存在")");
        if let footer = browser.browserFooter as? RTFooterView {
            footer.btn.isHidden = existOriginalImage;
        }
    }
    
    func rt_progressViewForBrowser<T>(browser: RTPhotoBrowser) -> T where T : UIView, T : RTProgressViewDelegate {
        let progressView = RTProgressView();
        
        return progressView as! T;
    }
}
