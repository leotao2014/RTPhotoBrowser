//
//  RTPhotoBrowser.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/3/13.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit

class RTPhotoBrowser: UIViewController {
    var showStyle: RTPhotoBrowserShowStyle = .weibo;
    var currentVisiblePageIndex:Int {
        return currentIndex;
    }
    
    fileprivate var currentIndex = 0;
    
    weak var delegate:RTPhotoBrowserDelegate?
    weak var browserFooter:UIView?
    weak var browserHeader:UIView?
    
    fileprivate let animator = ModalAnimator();
    fileprivate var photoArray:[RTPhotoModel] = [];
    fileprivate var visiblePages:Set<RTImagePage> = Set();
    fileprivate var recyclePages:Set<RTImagePage> = Set();
    fileprivate var viewActive = false;
    
    // MARK:Modal动画相关属性 scaleView和presentFinalView
    fileprivate var scaleView:UIImageView? {
        let imageView = UIImageView();
        let photoModel = photoAtIndex(index: currentIndex);
        imageView.image = RTImageFetcher.fetcher.fetchCacheImage(withUrl: photoModel?.picUrl);
        imageView.contentMode = .scaleAspectFill;
        imageView.clipsToBounds = true;
        
        return imageView;
    }
    
    fileprivate var presentFinalView:UIImageView? {
        let imageView = UIImageView();
        if let image = self.scaleView?.image {
            let containerBounds = frameForContainer;
            var pageBounds = pageFrameAtIndex(index: currentIndex, givenBounds: containerBounds);
            pageBounds.origin = .zero;
            imageView.frame = image.rt_calculateImageViewframe(givenBounds: pageBounds);
        }
        
        return imageView;
    }

    
    fileprivate var photoCounts:Int  {
        if let delegate = self.delegate {
            let photoCount = delegate.rt_numberOfPhotosForBrowser(browser: self);
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
        didStartViewPage(atIndex: currentIndex);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        viewActive = true;
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    deinit {
        print(#function);
        RTImageFetcher.fetcher.clearMemoryCache();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // 清除内存缓存并还原不显示原图的设置
        RTImageFetcher.fetcher.clearMemoryCache();
        self.photoArray.forEach { (model) in
            if model.viewOriginalPic {
                model.viewOriginalPic = false;
            }
        }
    }
// MARK:PublicMethods
    class func show(initialIndex: Int, delegate:RTPhotoBrowserDelegate, prsentedVC:UIViewController) -> RTPhotoBrowser {
        let browser = RTPhotoBrowser();
        browser.delegate = delegate;
        browser.currentIndex = initialIndex;
        browser.modalPresentationStyle = .custom;
        browser.transitioningDelegate = browser;
        prsentedVC.present(browser, animated: true, completion: nil);
        
        return browser;
    }
    
    // 设置需要显示原图
    func setNeedsDisplayOriginalPic() {
        if let photoModel = photoAtIndex(index: currentIndex), let page = pageAtIndex(index: currentIndex) {
            photoModel.viewOriginalPic = true;
            configurePage(page: page, atIndex: currentIndex);
        }
    }
    
    // 提供获取原图的接口
    func originalImage(atIndex index: Int) -> UIImage? {
        if let photo = photoAtIndex(index: index) {
            let image = RTImageFetcher.fetcher.fetchCacheImage(withUrl: photo.originalPicUrl);
            
            return image;
        }
        
        return nil;
    }
    
    // 提供获取普通质量图片的接口
    func image(atIndex index:Int) -> UIImage? {
        if let photo = photoAtIndex(index: index) {
            let image = RTImageFetcher.fetcher.fetchCacheImage(withUrl: photo.picUrl);
            return image;
        }
        
        return nil;
    }
    
// MARK:PrivateMethods
    private func commonSetup() {
        self.setNeedsStatusBarAppearanceUpdate();
        RTImageFetcher.fetcher.delegate = self;
        self.view.backgroundColor = UIColor.clear;
    }
    
    private func setupSubviews() {
        self.container.frame = frameForContainer;
        self.container.contentSize = contentSizeForContainer;
        if currentIndex != 0 {
            self.container.setContentOffset(contentOffset(atIndex: currentIndex), animated: false);
        }
        
        self.view.addSubview(self.container);
        
        if let footer = self.delegate?.rt_footerViewForBrowser(browser: self) {
            let footerHeight =  self.delegate!.rt_heightForFooterView(atIndex: currentIndex, browser: self);
            footer.frame = CGRect(x: 0, y: self.view.bounds.height - footerHeight, width: self.view.bounds.width, height: footerHeight);
            self.view.addSubview(footer);
            self.browserFooter = footer;
        }
        
        if let header = self.delegate?.rt_headerViewForBrowser(browser: self) {
            let headerHeight =  self.delegate!.rt_heightForHeaderView(atIndex: currentIndex, browser: self);
            header.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: headerHeight);
            self.view.addSubview(header);
            self.browserHeader = header;
        }
    }
    
    // 此处布局图片控件复用逻辑也在这里
    func layoutImagePages() {
        let bufferDistance:CGFloat = gap > 0 ? 2 : 0;
        let width = self.container.bounds.width;
        let interval = 2.0 * gap - bufferDistance;
        // 此处是2倍的gap
        let leftIndex = ((self.container.bounds.minX + interval) / width).rtIntValue;
        let rightIndex = ((self.container.bounds.maxX - interval) / width).rtIntValue;
        
        let totalCount = self.delegate?.rt_numberOfPhotosForBrowser(browser: self) ?? 0;
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
        page.frame = pageFrameAtIndex(index: index, givenBounds: self.container.bounds);
        var placeHolderImage = self.delegate?.rt_previewImage(atIndex: index, browser: self);
        if placeHolderImage == nil {
            placeHolderImage = RTPhotoBrowserConfig.defaulConfig.placeHolderImage;
        }
        
        page.setPhoto(photo: photoAtIndex(index: index), placeHolderImage: placeHolderImage);
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
                let tupel = delegate.rt_picUrlsForIndex(index: index, browser: self);
                let photoModel = RTPhotoModel(picUrls: tupel);
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
    
    func pageFrameAtIndex(index:Int, givenBounds:CGRect) -> CGRect {
        let rect = CGRect(x: givenBounds.width * index.rtFloatValue + gap, y: 0, width: givenBounds.width - 2 * gap, height: givenBounds.height);
        
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
        if let delegate = delegate {
            delegate.rt_pageDidAppear(atIndex: currentIndex, browser: self);
        }
        
        if let footer = self.browserFooter {
            let previousFooterH = footer.frame.height;
            let footerHeight =  self.delegate!.rt_heightForFooterView(atIndex: currentIndex, browser: self);
            if previousFooterH != footerHeight || footer.frame.origin.y == self.view.bounds.height {
                footer.frame = CGRect(x: 0, y: self.view.bounds.height - footerHeight, width: self.view.bounds.width, height: footerHeight);
            }
        }
        
        if let header = self.browserHeader {
            let previousHeaderH = header.frame.height;
            let headerHeight =  self.delegate!.rt_heightForHeaderView(atIndex: currentIndex, browser: self);
            if previousHeaderH != headerHeight {
                header.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: headerHeight);
            }
        }
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
            page.setImage(image: image, showProgress: false);
        } else {
            print("self.visiblePages -- photoModel.index = \(photoModel.index)");
            self.visiblePages.forEach({ (page) in
                print("self.visiblePages -- page.index = \(page.pageIndex)");
            })
        }
        
        
        if let delegate = self.delegate {
            delegate.rt_imageDidLoaded(atIndex: photoModel.index, browser: self);
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
        animator.startView = self.delegate?.rt_thumnailView(atIndex: currentIndex, browser: self);
        animator.scaleView = scaleView;
        animator.finalView = presentFinalView;
        
        return animator;
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.present = true;
        animator.startView = self.visiblePages.first?.imageView;
        animator.finalView = self.delegate?.rt_thumnailView(atIndex: currentIndex, browser: self);
        animator.scaleView = scaleView;
        
        if let presentController = self.presentationController as? RTPresentationController {
            // 将之前的需要隐藏的View更新成不隐藏状态
            presentController.viewNeedHidden?.isHidden = false;
            // 更新下需要隐藏的View
            presentController.viewNeedHidden = self.delegate?.rt_thumnailView(atIndex: currentIndex, browser: self);
        }
        
        return animator;
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentaionController: RTPresentationController = RTPresentationController(presentedViewController: presented, presenting: presenting)
        presentaionController.viewNeedHidden = self.delegate?.rt_thumnailView(atIndex: currentIndex, browser: self);

        return presentaionController;
    }
}

