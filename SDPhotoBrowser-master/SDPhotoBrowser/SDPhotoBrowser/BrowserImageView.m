//
//  BrowserImageView.m
//  SDPhotoBrowser
//
//  Created by dql on 15/3/12.
//  Copyright (c) 2015年 GSD. All rights reserved.
//

#import "BrowserImageView.h"
#import "SDWaitingView.h"
#import "UIImageView+WebCache.h"
#import "SDPhotoBrowserConfig.h"

@implementation BrowserImageView
{
    SDWaitingView *_waitingView;
//    BOOL _didCheckSize;
//    UIScrollView *_scroll;
//    UIImageView *_scrollImageView;
//    UIScrollView *_zoomingScroolView;
    UIImageView *_zoomingImageView;
    CGFloat _totalScale;
    BOOL _didImageFrameChanged;
    CGFloat _minScaleFactor;
    CGFloat _maxScaleFactor;
    BOOL _needSetScaleFactor;
}


//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.userInteractionEnabled = YES;
//        self.contentMode = UIViewContentModeScaleAspectFit;
//        _totalScale = 1.0;
//        
//        // 捏合手势缩放图片
//        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomImage:)];
//        [self addGestureRecognizer:pinch];
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        float width = frame.size.width;
        float height = width;
        _didImageFrameChanged = YES;
//        _zoomingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        _zoomingImageView = [[UIImageView alloc] init];
        [self addSubview:_zoomingImageView];
//
        self.delegate = self;
        _minScaleFactor = 1.0f;
//        self.contentInset = UIEdgeInsetsMake(SDPhotoBrowserImageViewMargin, SDPhotoBrowserImageViewMargin, SDPhotoBrowserImageViewMargin, SDPhotoBrowserImageViewMargin);
//        self.minimumZoomScale = 1.0f;
//        self.maximumZoomScale = 2.0f;
    }
    
    return self;
}

- (BOOL)isScaled
{
    return  1.0 != _totalScale;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _waitingView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    
    if (_needSetScaleFactor) {
        _needSetScaleFactor = NO;
        
//        self.minimumZoomScale = _minScaleFactor;
        self.maximumZoomScale = _maxScaleFactor;
    }
    
    if (_didImageFrameChanged) {
        _didImageFrameChanged = NO;
        float contentWidth = self.contentSize.width;
        float contentHeight = self.contentSize.height;
        
        float frameWidth = self.frame.size.width;
        float frameHeight = self.frame.size.height;
        
        float w = contentWidth > frameWidth ? contentWidth : frameWidth;
        float h = contentHeight > frameHeight ? contentHeight : frameHeight;
//        _zoomingImageView.center = CGPointMake(w * 0.5, h * 0.5);
        
        [UIView animateWithDuration:0.3f animations:^{
            _zoomingImageView.center = CGPointMake(w * 0.5, h * 0.5);
        }];
//        _zoomingImageView.bounds = CGRectMake(0, 0, _imageWidth, _imageHeight);
//        self.contentSize = CGSizeMake(w, h);
//        self.contentSize = CGSizeMake(<#CGFloat width#>, <#CGFloat height#>)
        
        NSLog(@"contentWidth:%f, frameWidth:%f, frame:%@", contentWidth, frameWidth, NSStringFromCGRect(_zoomingImageView.frame));
    }

}

- (void)setImageViewFrame:(CGRect)imageViewFrame
{
    _zoomingImageView.frame = imageViewFrame;
}

- (CGRect)imageViewFrame
{
    return _zoomingImageView.frame;
}

- (void)setImage:(UIImage *)image
{
    _zoomingImageView.image = image;
    _zoomingImageView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    self.contentSize = self.bounds.size;
}

- (UIImage *)image
{
    return _zoomingImageView.image;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    _waitingView.progress = progress;
    
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    SDWaitingView * waiting = [[SDWaitingView alloc] init];
    waiting.bounds = CGRectMake(0, 0, 100, 100);
    waiting.mode = SDWaitingViewProgressMode;
    _waitingView = waiting;
    [self addSubview:waiting];
    
    
    __weak BrowserImageView *imageViewWeak = self;
    
    [_zoomingImageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
        imageViewWeak.progress = (CGFloat)receivedSize / expectedSize;
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [imageViewWeak removeWaitingView];
        
        if (error) {
            UILabel *label = [[UILabel alloc] init];
            label.bounds = CGRectMake(0, 0, 160, 30);
            label.center = CGPointMake(imageViewWeak.bounds.size.width * 0.5, imageViewWeak.bounds.size.height * 0.5);
            label.text = @"图片加载失败";
            label.font = [UIFont systemFontOfSize:16];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            label.layer.cornerRadius = 5;
            label.clipsToBounds = YES;
            label.textAlignment = NSTextAlignmentCenter;
            [imageViewWeak addSubview:label];
            
        }
        else {
            
            // 根据图片的大小不同，进行不同比例的缩放
            float width = image.size.width;
            float height = image.size.height;
            
            float widFactor = width / imageViewWeak.bounds.size.width;
            float heightFacor = height / imageViewWeak.bounds.size.height;
            
            _maxScaleFactor = MAX(widFactor, heightFacor);
            _needSetScaleFactor = YES;
//            [UIView animateWithDuration:0.3f animations:^{
//                _zoomingImageView.bounds = CGRectMake(0, 0, width, height);
//            }];
//            
            
//
//            _imageWidth = width;
//            _imageHeight = height;
//            _didImageFrameChanged = YES;
//            CGRect rect = _zoomingImageView.frame;
//            _zoomingImageView.bounds = CGRectMake(0, 0, width, height);
//            _zoomingImageView.center = self.center;
//            self.contentSize = CGSizeMake(width, height);
        }
        
    }];
}

#pragma mark - UIScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // 目前添加，图片宽度比屏幕窄的图片不支持缩放
    float width = self.bounds.size.width;
    if (_zoomingImageView.image.size.width < width) {
        return nil;
    }
    return _zoomingImageView;
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    _didImageFrameChanged = YES;
    
    [self setNeedsLayout];
}

// 清除缩放，目前还有问题
- (void)eliminateScale
{
//    [_zoomingScroolView removeFromSuperview];
//    _zoomingScroolView = nil;
//    _zoomingImageView = nil;
//    _totalScale = 1.0;
//    self.zoomScale = 1.0f;
//    _didImageFrameChanged = YES;
//    [self setNeedsDisplay];
}

- (void)removeWaitingView
{
    [_waitingView removeFromSuperview];
}


@end
