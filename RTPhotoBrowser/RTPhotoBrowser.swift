//
//  RTPhotoBrowser.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/3/13.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

@objc protocol RTPhotoBrowserDelegate: NSObjectProtocol {
    func numberOfPhotosForBrowser() -> Int;
    func photoForIndex(index: Int) -> RTPhotoModel;
    @objc optional func sourceImageViewForIndex(index: Int) -> UIImageView?
}

enum RTPhotoBrowserShowStyle {
    case normal;
    case weibo;
}

let gap:CGFloat = 10.0;

class RTPhotoBrowser: UIViewController {
    var showStyle: RTPhotoBrowserShowStyle = .weibo;
    weak var delegate:RTPhotoBrowserDelegate?
    
    private var visiblePages:Set<RTImagePage> = Set();
    private var recyclePages:Set<RTImagePage> = Set();
    // MARK: 计算属性
    private var frameForContainer:CGRect {
        let rect = CGRect(x: -gap, y: 0, width: self.view.bounds.width + 2.0 * gap, height: self.view.bounds.height);
        return rect;
    }
    
    private var contentSizeForContainer:CGSize {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(RTPhotoBrowserDelegate.numberOfPhotosForBrowser)) {
                let photoCount = delegate.numberOfPhotosForBrowser();
                let contentSize = CGSize(width:  photoCount.rtFloatValue * frameForContainer.width, height: 0);
                
                return contentSize;
            }
        }
        
        return .zero;
    }
    
    private lazy var container: UIScrollView = { [unowned self] in
        let scrollView = UIScrollView();
        scrollView.isPagingEnabled = true;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.backgroundColor = UIColor.black;
        scrollView.delegate = self;
        
        return scrollView;
    }();

// MARK:LifeCircle
    init() {
        super.init(nibName: nil, bundle: nil);
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commonSetup();
        setupSubviews();
        layoutImagePages();
    }
    
// MARK:PrivateMethods
    private func commonSetup() {
        self.view.backgroundColor = UIColor.white;
    }
    
    private func setupSubviews() {
        self.container.frame = frameForContainer;
        self.container.contentSize = contentSizeForContainer;
        self.view.addSubview(self.container);
        
        
    }
    
    func layoutImagePages() {
        let bufferDistance:CGFloat = 2;
        let width = self.container.bounds.width;
        let leftIndex = ((self.container.bounds.minX + 1.rtFloatValue * gap - bufferDistance) / width).rtIntValue;
        let rightIndex = ((self.container.bounds.maxX - 1.rtFloatValue * gap + bufferDistance) / width).rtIntValue;
        let totalCount = self.delegate?.numberOfPhotosForBrowser() ?? 0;
        guard leftIndex >= 0 && rightIndex < totalCount else {
            return;
        }
        
        for i in leftIndex...rightIndex {
            if !pageExistAtIndex(index: i) {
                if let page = dequePageFromRecycleSet() {   // 从缓存池中取出来
                    page.pageIndex = i;
                    page.frame = pageFrameAtIndex(index: i);
                } else {    // 如果从缓存池中没有取出 则新建一个
                    let page = RTImagePage();
                    page.backgroundColor = UIColor.randomColor();
                    page.pageIndex = i;
                    page.frame = pageFrameAtIndex(index: i);
                    self.container.addSubview(page);
                    self.visiblePages.insert(page);
                }
            }
        }
    }
    
    func pageExistAtIndex(index:Int) -> Bool {
        for page in self.visiblePages {
            if page.pageIndex == index {
                return true;
            }
        }
        
        return false;
    }
    
    func pageFrameAtIndex(index:Int) -> CGRect {
        let rect = CGRect(x: self.container.bounds.width * index.rtFloatValue + gap, y: 0, width: self.container.bounds.width - 2 * gap, height: self.container.bounds.height);
        
        return rect;
    }
    
    func dequePageFromRecycleSet() -> RTImagePage? {
        if let page = self.recyclePages.first {
            self.recyclePages.remove(page);
            return page;
        } else {
            return nil;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true, completion: nil);
    }
}

extension RTPhotoBrowser: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.x);
        layoutImagePages();
    }
}

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

