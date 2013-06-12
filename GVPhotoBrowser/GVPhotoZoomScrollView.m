//
//  GVPhoto.m
//  Example
//
//  Created by Kevin Renskers on 12-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import "GVPhotoZoomScrollView.h"

@implementation GVPhotoZoomScrollView

- (void)setImageView:(UIImageView *)imageView {
    _imageView = imageView;

    self.clipsToBounds = YES;
    self.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    self.minimumZoomScale = 0.3;
    self.maximumZoomScale = 3;
    self.zoomScale = 1;

    [self addSubview:_imageView];

    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;

    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }

    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }

    self.imageView.frame = contentsFrame;
}

@end
