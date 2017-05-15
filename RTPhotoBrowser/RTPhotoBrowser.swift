//
//  RTPhotoBrowser.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/3/13.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit
import Kingfisher

protocol RTPhotoBrowserDelegate : NSObjectProtocol {
    func numberOfPhotosForBrowser() -> Int;
    func photoForIndex(index: Int) -> RTPhotoModelDelegate;
    // optional
    func thumnailViewForIndex(index: Int) -> UIView?
}

extension RTPhotoBrowserDelegate {
    func thumnailViewForIndex(index: Int) -> UIView? {
        return nil;
    }
}


enum RTPhotoBrowserShowStyle {
    case normal;
    case weibo;
    case twitter;
}

let gap:CGFloat = 5.0;

class RTPhotoBrowser: UIViewController {
    
    var showStyle: RTPhotoBrowserShowStyle = .weibo;
    var currentIndex = 0;
    
    weak var delegate:RTPhotoBrowserDelegate?
    
    fileprivate let animator = ModalAnimator();
    fileprivate var photoArray:[RTPhotoModel] = [];
    fileprivate var visiblePages:Set<RTImagePage> = Set();
    fileprivate var recyclePages:Set<RTImagePage> = Set();
    fileprivate var viewActive = false;
    fileprivate var scaleView:UIImageView? {
        let imageView = UIImageView();
        imageView.image = self.visiblePages.first?.imageView.image;
        imageView.contentMode = .scaleAspectFill;
        imageView.clipsToBounds = true;
        
        return imageView;
    }
    
    fileprivate var photoCounts:Int  {
        if let delegate = self.delegate {
            let photoCount = delegate.numberOfPhotosForBrowser();
            return photoCount;
        }
        
        return 0;
    }
    
    
    
    // MARK: 计算属性
    fileprivate var frameForContainer:CGRect {
        let rect = CGRect(x: -gap, y: 0, width: self.view.bounds.width + 2.0 * gap, height: self.view.bounds.height);
        return rect;
    }
    
    fileprivate var contentSizeForContainer:CGSize {
        let photoCount = photoCounts;
        let contentSize = CGSize(width:  photoCount.rtFloatValue * frameForContainer.width, height: 0);
        return contentSize;
    }
    
    fileprivate lazy var container: UIScrollView = { [unowned self] in
        let scrollView = UIScrollView();
        scrollView.isPagingEnabled = true;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.backgroundColor = UIColor.clear;
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
        
        print(#function);
        commonSetup();
        setupSubviews();
        layoutImagePages();
        animatorSetup();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        viewActive = true;
    }
    
    deinit {
        print(#function);
        ImageCache.default.clearMemoryCache();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
// MARK:PrivateMethods
    private func commonSetup() {
        RTImageFetcher.fetcher.delegate = self;
        self.view.backgroundColor = UIColor.white;
    }
    
    private func animatorSetup() {
        animator.finalView = self.visiblePages.first?.imageView;
        scaleView?.image = self.visiblePages.first?.imageView.image;
        animator.scaleView = scaleView;
    }
    
    private func setupSubviews() {
        self.container.frame = frameForContainer;
        self.container.contentSize = contentSizeForContainer;
        if currentIndex != 0 {
            self.container.setContentOffset(contentOffset(atIndex: currentIndex), animated: false);
        }
        
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
        
        // 回收已经不显示的page
        self.visiblePages.forEach { (page) in
            if page.pageIndex > rightIndex || page.pageIndex < leftIndex {
                self.recyclePages.insert(page);
            }
        }
        
        self.recyclePages.forEach { (page) in
            self.visiblePages.remove(page);
        }
      
        for i in leftIndex...rightIndex {
            if !pageExistAtIndex(index: i) {    // 当前页上没有page则执行取page逻辑
                var page = dequePageFromRecycleSet();   // 先从缓存池中取
                if page == nil {    // 没有取出则新建一个
                    page = RTImagePage();
                    self.container.addSubview(page!);
                } else {
                    page!.prepareForReuse();
                }
                
                // 在设置page之前进行插入动作 因为在page!.photo = photoAtIndex(index: i);这一步操作时进行了获取图片操作
                // 如果获取图片在self.visiblePages.insert(page!);之前完成的话由于在self.visiblePages找不到对应index的page会导致
                // 图片不会进行赋值操作也就是不显示图片
                self.visiblePages.insert(page!);
                configurePage(page: page!, atIndex: i);
            }
        }
    }
    
    func configurePage(page:RTImagePage, atIndex index:Int) {
        page.singleTapHandler = { [weak self] in
            self?.dismiss(animated: true, completion: nil);
        }
        
        page.pageIndex = index;
        page.frame = pageFrameAtIndex(index: index);
        page.photo = photoAtIndex(index: index);
    }
    
    func pageExistAtIndex(index:Int) -> Bool {
        let page = pageAtIndex(index: index);
        
        return page != nil;
    }
    
    func pageAtIndex(index:Int) -> RTImagePage? {
        let result = self.visiblePages.filter { (page) -> Bool in
            return (page.pageIndex == index);
        }
                
        return result.first;
    }
    
    func photoAtIndex(index:Int) -> RTPhotoModel? {
        let result = self.photoArray.filter { (model) -> Bool in
            return model.index == index;
        }
        
        let photo = result.first;
        if photo == nil {
            if let delegate = self.delegate {
                let model = delegate.photoForIndex(index: index);
                let photoModel = RTPhotoModel(model: model);
                photoModel.index = index;
                self.photoArray.append(photoModel);
                return photoModel;
            }
        }
        
        return photo;
    }
    
    func contentOffset(atIndex: Int) -> CGPoint {
        return CGPoint(x: currentIndex.rtFloatValue * container.frame.width, y: 0);
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

extension RTPhotoBrowser: RTImageFetchDelegate {
    func imageDidLoaded(image: UIImage, photoModel: RTPhotoModel) {
        print("image下载完毕");
        if let page = pageAtIndex(index: photoModel.index) {
            page.setImage(image: image);
        } else {
            print("self.visiblePages -- photoModel.index = \(photoModel.index)");
            self.visiblePages.forEach({ (page) in
                print("self.visiblePages -- page.index = \(page.pageIndex)");
            })
        }
        
        
    }
    
    func imageDidFailLoad(error: Error?, photoModel: RTPhotoModel) {
        print("image下载失败 index = \(photoModel.index) currentIndex = \(currentIndex) error = \(error!)");
        if let page = pageAtIndex(index: photoModel.index) {
            page.imageLoadFail(error: error);
        }
    }
    
    func imageLoadingUpdateProgress(progress: CGFloat, photoModel: RTPhotoModel) {
        print("image正在下载 index = \(photoModel.index) currentIndex = \(currentIndex)");
        if let page = pageAtIndex(index: photoModel.index) {
            page.updateImageLoadProgress(progress: progress);
        }
    }
}

extension RTPhotoBrowser: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.present = true;
        animator.startView = self.delegate?.thumnailViewForIndex(index: currentIndex);
        
        return animator;
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.present = true;
        animator.startView = self.visiblePages.first?.imageView;
        animator.finalView = self.delegate?.thumnailViewForIndex(index: currentIndex);
        animator.scaleView = scaleView;
        
        return animator;
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentaionController: RTPresentationController = RTPresentationController(presentedViewController: presented, presenting: presenting)
        presentaionController.viewNeedHidden = self.delegate?.thumnailViewForIndex(index: currentIndex);
        
        return presentaionController;
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

