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

let gap:CGFloat = 5.0;

class RTPhotoBrowser: UIViewController {
    
    var showStyle: RTPhotoBrowserShowStyle = .weibo;
    weak var delegate:RTPhotoBrowserDelegate?
    
    private var visiblePages:Set<RTImagePage> = Set();
    private var recyclePages:Set<RTImagePage> = Set();
    var viewActive = false;
    var currentIndex = 0;
    var photoCounts:Int  {
        if let delegate = self.delegate {
            if delegate.responds(to: #selector(RTPhotoBrowserDelegate.numberOfPhotosForBrowser)) {
                let photoCount = delegate.numberOfPhotosForBrowser();
                return photoCount;
            }
        }
        
        return 0;
    }
    
    // MARK: 计算属性
    private var frameForContainer:CGRect {
        let rect = CGRect(x: -gap, y: 0, width: self.view.bounds.width + 2.0 * gap, height: self.view.bounds.height);
        return rect;
    }
    
    private var contentSizeForContainer:CGSize {
        let photoCount = photoCounts;
        let contentSize = CGSize(width:  photoCount.rtFloatValue * frameForContainer.width, height: 0);
        
        return contentSize;
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        viewActive = true;
    }
    
    deinit {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        let bufferDistance:CGFloat = gap > 0 ? 2 : 0;
        let width = self.container.bounds.width;
        let interval = 2.0 * gap - bufferDistance;
        // 此处是2倍的gap
        let leftIndex = ((self.container.bounds.minX + interval) / width).rtIntValue;
        let rightIndex = ((self.container.bounds.maxX - interval) / width).rtIntValue;
        
        let totalCount = self.delegate?.numberOfPhotosForBrowser() ?? 0;
        guard leftIndex >= 0 && rightIndex < totalCount else {
            return;
        }
        
        for page in self.visiblePages {
            if page.pageIndex > rightIndex || page.pageIndex < leftIndex {
                self.visiblePages.remove(page);
                self.recyclePages.insert(page);
            }
        }
      
        for i in leftIndex...rightIndex {
            if !pageExistAtIndex(index: i) {    // 当前页上没有page则执行取page逻辑
                var page = dequePageFromRecycleSet();   // 先从缓存池中取
                if page == nil {    // 没有取出则新建一个
                    page = RTImagePage();
                    page!.backgroundColor = UIColor.randomColor();
                    self.container.addSubview(page!);
                }
                
                page!.pageIndex = i;
                page!.frame = pageFrameAtIndex(index: i);
                self.visiblePages.insert(page!);
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
    
    func didStartViewPage(atIndex index:Int) {
        print(#function, index);
    }
}

extension RTPhotoBrowser: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if viewActive {
            layoutImagePages();
            
            var index = (scrollView.contentOffset.x / scrollView.bounds.width).rtIntValue;
            index = index < 0 ? 0 : index;
            index = index > photoCounts - 1 ? photoCounts - 1 : index;
            
            let previousIndex = currentIndex;
            currentIndex = index;
            if previousIndex != currentIndex {
                didStartViewPage(atIndex: currentIndex);
            }
        }
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

