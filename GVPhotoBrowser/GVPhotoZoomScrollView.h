//
//  GVPhoto.h
//  Example
//
//  Created by Kevin Renskers on 12-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVPhotoZoomScrollView : UIScrollView

@property (strong, nonatomic) UIImageView *imageView;

- (void)centerScrollViewContents;

@end
