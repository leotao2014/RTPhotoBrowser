//
//  RTImagePage.swift
//  RTPhotoBrowser
//
//  Created by leotao on 2017/3/13.
//  Copyright © 2017年 leotao. All rights reserved.
//

import UIKit
import Kingfisher

class RTImagePage: UIScrollView {
    var imageView: UIImageView = {
        let iv = UIImageView();
        iv.contentMode = .scaleAspectFill;
        iv.clipsToBounds = true;
        
        return iv;
    }();
    
    var progressView:RTProgressViewDelegate!
    
    var singleTapHandler:(()->Void)?;
    var pageIndex:Int = 0;
    
    var photo:RTPhotoModel?
    init(progressView: RTProgressViewDelegate) {
        super.init(frame: .zero);
        
        guard (progressView as AnyObject).isKind(of: UIView.self) else {
            assertionFailure("ProgressView must be a UIView");
            return;
        }
        
        self.progressView = progressView;
        commonSetup();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        commonSetup();
    }
    
    func commonSetup() {
        addSubview(imageView);
        addSubview(progressView as! UIView);
        self.delegate = self;
        self.backgroundColor = UIColor.black;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareForReuse() {
        self.imageView.image = nil;
        (self.progressView as! UIView).isHidden = true;
        self.progressView.rt_setProgress(progress: 0.02);
    }
    
    func setPhoto(photo:RTPhotoModel?, placeHolderImage:UIImage?) {
        if let photo = photo {
            RTImageFetcher.fetcher.fetchImage(photo: photo);
            if self.imageView.image == nil {
                (self.progressView as! UIView).isHidden = false;
                layoutComponents();
                if let placeHolderImage = placeHolderImage {
                    setImage(image: placeHolderImage, showProgress: true);
                }
            }

        }
    }
    
    func setImage(image: UIImage, showProgress:Bool) {
        print(#function, image);
        
        self.imageView.image = image;
        (self.progressView as! UIView).isHidden = !showProgress;
        
        setNeedsUpdateFrameForComponents();
    }
    
    func setNeedsUpdateFrameForComponents() {
        setupZoomScale();
        layoutComponents();
    }
    
    func layoutComponents() {
        // progress的frame和image存不存在不相关
        let pWidth:CGFloat = kProgressViewWidth;
        let pHeight = pWidth;
        (self.progressView as! UIView).frame = CGRect(x: (self.bounds.width - pWidth) * 0.5, y: (self.bounds.height - pHeight) * 0.5, width: pWidth, height: pHeight);
        
        guard let image = self.imageView.image else {
            return;
        }
        
        self.imageView.frame = image.rt_calculateImageViewframe(givenBounds: self.bounds);
        self.contentSize = self.imageView.frame.size;
    }
    
    
    func centerImageView() {
        let width = self.imageView.frame.width;
        let height = self.imageView.frame.height;
        self.contentSize = self.imageView.frame.size;
        var x = (self.frame.size.width - width) * 0.5;
        var y = (self.frame.size.height - height) * 0.5;
        x = max(0, x);
        y = max(0, y);
        
        self.imageView.frame = CGRect(x: x, y: y, width: self.imageView.frame.width, height: self.imageView.frame.height);
    }
    
    func setupZoomScale() {
        guard let image = self.imageView.image else { return };
        
        let width = min(self.frame.width, self.frame.height);
        self.maximumZoomScale = (((image.size.width) / UIScreen.main.scale) * 3) / width;
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            switch touch.tapCount {
            case 1:
                // 延迟单击操作
                self.perform(#selector(handleSingleTap(touch:)), with: touch, afterDelay: 0.3);
            case 2:
                // 如果是双击操作。则双击方法会先执行。并在双击方法里取消单击操作
                handleDoubleTap(touch: touch);
            default:
                break;
            }
        }
    }
    
    func handleSingleTap(touch:UITouch) {
        print(touch.tapCount);
        if let closure = self.singleTapHandler {
            closure();
        }
    }
    
    func handleDoubleTap(touch:UITouch) {
        // 取消单击操作
        NSObject.cancelPreviousPerformRequests(withTarget: self);
        
        let point = touch.location(in: self);
        let convertPoint = self.convert(point, to: self.imageView);
        print(convertPoint, point);
        
        if self.zoomScale > self.minimumZoomScale {
            self.setZoomScale(self.minimumZoomScale, animated: true);
        } else {
            let zoomScale = (self.maximumZoomScale + self.minimumZoomScale) * 0.5;
            let zoomWidth = self.frame.size.width / zoomScale;
            let zoomHeigh = self.frame.size.height / zoomScale;
            let zoomX = convertPoint.x - zoomWidth * 0.5;
            let zoomY = convertPoint.y - zoomHeigh * 0.5;
            let zoomRect = CGRect(x: zoomX, y: zoomY, width: zoomWidth, height: zoomHeigh);
            self.zoom(to: zoomRect, animated: true);
        }
    }
    
    override var frame: CGRect {
        willSet {
            print("现在的frame是\(frame)frame将要改变成\(newValue)")
        }
    }
}

// MARK:ImageFetchHandle
extension RTImagePage {
    func imageLoadFail(error:Error?) {
        (self.progressView as! UIView).isHidden = true;
        if let failImage = RTPhotoBrowserConfig.defaulConfig.loadFailImage {
            setImage(image: failImage, showProgress: false);
        }
    }
    
    func updateImageLoadProgress(progress:CGFloat) {
        let progress = min(max(0.02, progress), 1.0);
        if progress == 1.0 {
            (self.progressView as! UIView).isHidden = true;
        } else {
            (self.progressView as! UIView).isHidden = false;
        }
        
        progressView.rt_setProgress(progress: progress);
    }
}

// MARK:UIScrollViewDelegate
extension RTImagePage: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if (self.progressView as! UIView).isHidden {
            return self.imageView;
        }
        
        return nil;
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView();
    }
}

