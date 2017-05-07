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
    
    var progressView = RTProgressView();
    
    var singleTapHandler:(()->Void)?;
    var pageIndex:Int = 0;
    var setNeedsPresentAnimation = false;
    var sourceFrame:CGRect?
    var completionHandler:((Void)->Void)?
    
    var photo:RTPhotoModel? {
        didSet {
            if let photo = photo {
                RTImageFetcher.fetcher.fetchImage(photo: photo);
                let result = ImageCache.default.isImageCached(forKey: photo.picUrl);
                if result.cached == false { // 如果没有缓存则显示loading界面
                    self.progressView.isHidden = false;
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        addSubview(imageView);
        addSubview(progressView);
        self.delegate = self;
        self.backgroundColor = UIColor.black;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//  在放大图片时会不断调用layoutSubViews方法
    override func layoutSubviews() {
        super.layoutSubviews();
        let pWidth:CGFloat = kProgressViewWidth;
        let pHeight = pWidth;
        progressView.frame = CGRect(x: (self.bounds.width - pWidth) * 0.5, y: (self.bounds.height - pHeight) * 0.5, width: pWidth, height: pHeight);
    }
    
    func prepareForReuse() {
        self.imageView.image = nil;
        self.progressView.isHidden = true;
        self.progressView.progress = 0.02;
    }
    
    func setImage(image: UIImage) {
        print(#function, image);
        
        self.imageView.image = image;
        setupZoomScale();
        setImageViewFrame();
        
        if self.setNeedsPresentAnimation {
            weiboPresentAnimation();
        }
    }
    
    func setImageViewFrame() {
        guard let image = self.imageView.image else {
            return;
        }
        
        var x:CGFloat = 0;
        var size:CGSize = .zero;
        if image.size.width < self.frame.size.width && image.size.height < self.frame.size.height {
            size = image.size;
            x = (self.frame.size.width - size.width) * 0.5;
        } else {
            let heightScale = image.size.height / self.frame.height;
            let widthScale = image.size.width / self.frame.width;
            let scale = image.size.height / image.size.width;
            print("heightScale = \(heightScale) widthScale = \(widthScale) scale = \(scale) image.size = \(image.size) self.frame = \(self.frame.size)");
            if heightScale > 1.0 && heightScale <= 1.51 && widthScale <= 1.1 {   // 虽然此时图片高度大于屏幕高度，但是高的不明显(倍数不超过1.51.根据qq中的相册反复试验得出)。所以不看成长图
                size.height = self.frame.size.height;
                size.width = size.height / scale;
                x = (self.frame.size.width - size.width) * 0.5;
            } else {
                size.width = self.frame.size.width;
                size.height = self.frame.size.width * scale;
            }
        }
        
        var y:CGFloat = 0;
        if size.height < self.frame.size.height {
            y = (self.frame.height - size.height) * 0.5;
        }
        self.imageView.frame = CGRect(x: x, y: y, width: size.width, height: size.height);
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
            //            print("self.zoomScale = \(self.zoomScale) cacluateScale = \(zoomScale) self.max = \(self.maximumZoomScale) self.min = \(self.minimumZoomScale)");
        }
    }
}

// MARK:Animations
extension RTImagePage {
    
    func startPresentAnimation(style: RTPhotoBrowserShowStyle, sourceFrame:CGRect?, completionHandler:@escaping (Void)->Void) {
        self.imageView.isHidden = true;
        
        print(#function);
        var realStyle = style;
        if style == .weibo && sourceFrame == nil {
            realStyle = .normal;
        }
        
        switch realStyle {
        case .weibo:
            let result = ImageCache.default.isImageCached(forKey: self.photo!.picUrl);
            self.sourceFrame = sourceFrame;
            self.completionHandler = completionHandler;
            if result.cached {  // 如果已缓存则等待image获取完毕开始动画
                if self.imageView.image != nil {
                    weiboPresentAnimation();
                } else {
                    self.setNeedsPresentAnimation = true;
                }
            } else {
                weiboPresentAnimation();
            }
        case .normal: break
        case .twitter: break
        }
    }
    
    func weiboPresentAnimation() {
        self.setNeedsPresentAnimation = false;
        if let _ = self.imageView.image {
            let tempImgView = UIImageView();
            tempImgView.image = self.imageView.image;
            tempImgView.frame = sourceFrame!;
            self.addSubview(tempImgView);
            UIView.animate(withDuration: 0.25, animations: {
                tempImgView.frame = self.imageView.frame;
            }, completion: { (_) in
                tempImgView.removeFromSuperview();
                self.completeAnimation();
            })
        } else {
            completeAnimation();
        }
    }
    
    func completeAnimation() {
        self.imageView.isHidden = false;
        self.completionHandler!();
        // 去除循环引用
        self.completionHandler = nil;
    }
    
    func startDismissAnimation(style: RTPhotoBrowserShowStyle, sourceFrame:CGRect?, completionHandler:@escaping (Void)->Void) {
        var realStyle = style;
        if style == .weibo && sourceFrame == nil {
            realStyle = .normal;
        }
        
        switch realStyle {
            case .weibo:
                self.backgroundColor = UIColor.black.withAlphaComponent(0.8);
                UIView.animate(withDuration: 0.25, animations: {
                    self.backgroundColor = UIColor.black.withAlphaComponent(0.0);
                    self.imageView.frame = sourceFrame!;
                }, completion: { (_) in
                    self.imageView.isHidden = true;
                    completionHandler();
                    
                })
            case .twitter:break;
            case .normal: break;
        }
    }
}

// MARK:ImageFetchHandle
extension RTImagePage {
    func imageLoadFail(error:Error?) {
        print(#function);
        self.progressView.isHidden = true;
        self.setImage(image: UIImage(named: "fail")!);
    }
    
    func updateImageLoadProgress(progress:CGFloat) {
        print("updateImageLoadProgress\(progress)");
        var progress = max(0.02, progress);
        progress = min(progress, 1.0);
        
        if progress == 1.0 {
            progressView.isHidden = true;
        } else {
            progressView.isHidden = false;
        }
        
        
        progressView.progress = progress;
    }
}

// MARK:UIScrollViewDelegate
extension RTImagePage: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView;
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView();
    }
}


