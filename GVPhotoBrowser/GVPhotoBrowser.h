//
//  GVPhotoBrowser.h
//  Example
//
//  Created by Kevin Renskers on 09-06-13.
//  Copyright (c) 2013 Gangverk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GVPhotoBrowser;


@protocol GVPhotoBrowserDataSource <NSObject>
// How many photos do you want to show?
@required
- (NSUInteger)numberOfPhotosInPhotoBrowser:(GVPhotoBrowser *)photoBrowser;

// The method is passed an imageview that's set up with the correct content mode, auto resizing mask, etc.
// You can modify the imageview as you see fit, set its image property, add subviews, whatever you want.
@required
- (UIImageView *)photoBrowser:(GVPhotoBrowser *)photoBrowser modifyImageView:(UIImageView *)imageView forIndex:(NSUInteger)index;

// The imageview that's passed to the photoBrowser:modifyImageView:forIndex: method is created by GVPhotoBrowser.
// You can also create your own "base" imageview that's then passed to that method instead.
@optional
- (UIImageView *)baseImageViewForPhotoBrowser:(GVPhotoBrowser *)photoBrowser;

@end


@protocol GVPhotoBrowserDelegate <NSObject, UIScrollViewDelegate, UIScrollViewDelegate>
@optional
- (void)photoBrowser:(GVPhotoBrowser *)photoBrowser didSwitchToIndex:(NSUInteger)index;
@end


@interface GVPhotoBrowser : UIScrollView

@property (weak, nonatomic) IBOutlet id <GVPhotoBrowserDataSource> dataSource;
@property (weak, nonatomic) IBOutlet id <GVPhotoBrowserDelegate> delegate;
@property (nonatomic) NSInteger currentIndex;

@end
